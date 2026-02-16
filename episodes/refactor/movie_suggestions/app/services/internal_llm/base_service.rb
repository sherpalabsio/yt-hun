# frozen_string_literal: true

class InternalLlm::BaseService
  CONFIG = Rails.application.config_for(:internal_llm)

  REQUEST_TIMEOUT = 25
  REQUEST_RETRIES = 3
  RETRIABLE_STATUSES = [502].freeze
  OK_STATUSES = [200, 201, 204].freeze

  attr_reader :error, :status

  def initialize
    @error = nil
    @status = nil
    @base_uri = CONFIG["base_url"]
    @llm_token = CONFIG["token"]
  end

  def retriable?
    @retriable
  end

  def reset
    @error = nil
    @status = nil
    @retriable = nil
  end

  private

  def send_request_and_capture_errors(path, method: :post, body: nil, params: nil)
    response = perform_request(path, method, body: body, params: params)
    if OK_STATUSES.include?(response.status)
      return response.body.present? ? JSON.parse(response.body) : {}
    end

    @status = response.status
    @error = "#{response.status} #{response.reason_phrase}"
    if RETRIABLE_STATUSES.include?(status)
      @retriable = true
    else
      Sentry.capture_message(error)
    end

    nil
  rescue Faraday::TimeoutError
    @error = "Internal LLM endpoint #{path} is taking too long to respond"
    Rails.logger.warn "Internal LLM request failed due to Faraday::TimeoutError"
  rescue StandardError => e
    @error = e.message
    Sentry.capture_exception(e)
  end

  def perform_request(path, method, body: nil, params: nil)
    url = URI("#{@base_uri}/#{path}")
    connection = Faraday.new(url: url, request: { timeout: REQUEST_TIMEOUT }, params: params) do |conn|
      conn.request(:retry, max: REQUEST_RETRIES)
      conn.adapter :httpclient
    end

    connection.public_send(method, url) do |request|
      request.body = body.presence || {}.to_json
      sign_request(request)
      request.headers[:accept] = "application/json"
      request.headers["Content-Type"] = "application/json"
    end
  end

  def sign_request(request)
    request.headers["X-Internal-LLM-Token"] = @llm_token
  end
end
