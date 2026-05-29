require "http"
require "base64"
require "json"

class ReceiptScanner
  ENDPOINT = "https://api.openai.com/v1/chat/completions".freeze
  MODEL = "gpt-4o-mini".freeze

  PROMPT = <<~PROMPT.freeze
    You are reading a retail receipt image. Extract these fields and return JSON.
    - store_name: the name of the store (string)
    - total_amount: the FINAL total in dollars as a plain number, no $ sign, no commas (number)
    - date: the date on the receipt in YYYY-MM-DD format; if year is missing, assume #{Date.current.year} (string)
    - description: a 3-7 word summary of what was purchased (string)

    Return ONLY valid JSON with these exact keys: store_name, total_amount, date, description.
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
                   .timeout(60)
                   .post(ENDPOINT, json: payload)

    unless response.status.success?
      raise "OpenAI API error: #{response.code} #{response.body}"
    end

    content = response.parse.dig("choices", 0, "message", "content").to_s
    content = content.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "").strip

    Rails.logger.info "ReceiptScanner raw response: #{content}"

    JSON.parse(content)
  end

  private

  def payload
    {
      model: MODEL,
      response_format: { type: "json_object" },
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: PROMPT },
            { type: "image_url", image_url: { url: data_url } }
          ]
        }
      ],
      max_tokens: 400
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
