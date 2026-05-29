require "http"
require "base64"
require "json"

class ReceiptScanner
  ENDPOINT = "https://api.openai.com/v1/chat/completions".freeze
  MODEL = "gpt-4o-mini".freeze

  PROMPT = <<~PROMPT.freeze
    You are reading a retail receipt image. Extract these fields:
    - store_name: the name of the store
    - total_amount: the total in dollars as a number, no $ sign
    - date: the date on the receipt in YYYY-MM-DD format; if year is missing, assume #{Date.current.year}
    - description: a 3-7 word summary of what was purchased

    Reply with ONLY valid JSON, no other text, in this exact format:
    {"store_name": "...", "total_amount": 0.00, "date": "YYYY-MM-DD", "description": "..."}
  PROMPT

  def self.call(blob)
    new(blob).call
  end

  def initialize(blob)
    @blob = blob
  end

  def call
    response = HTTP.auth("Bearer #{api_key}")
                   .headers(content_type: "application/json")
                   .post(ENDPOINT, json: payload)

    unless response.status.success?
      raise "OpenAI API error: #{response.code} #{response.body}"
    end

    content = response.parse.dig("choices", 0, "message", "content").to_s

    # Strip markdown code block wrapping if the model returned one
    content = content.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "").strip

    Rails.logger.info "ReceiptScanner raw response: #{content}"

    JSON.parse(content)
  end

  private

  def payload
    {
      model: MODEL,
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: PROMPT },
            { type: "image_url", image_url: { url: data_url } }
          ]
        }
      ],
      max_tokens: 300
    }
  end

  def data_url
    encoded = Base64.strict_encode64(@blob.download)
    mime = @blob.content_type || "image/jpeg"
    "data:#{mime};base64,#{encoded}"
  end

  def api_key
    ENV.fetch("OPENAI_API_KEY")
  end
end
