class HelloWorldJob < ApplicationJob
  queue_as :default

  def perform(name)
    Rails.logger.info "===> Hello from background job, #{name}! Time: #{Time.current}"
    puts "===> Hello from background job, #{name}! Time: #{Time.current}"
  end
end
