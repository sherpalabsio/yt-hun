require "rails_helper"

RSpec.describe Movies::SuggestionsController do
  let(:internal_llm_config) { InternalLlm::BaseService::CONFIG }
  let(:internal_llm_base_url) { internal_llm_config["base_url"] }

  let(:user) { users(:one) }

  before(:each) do
    Rails.cache.clear
  end

  describe "GET #index" do
    before do
      allow_any_instance_of(UserPreferenceCalculator).to receive(:calculate_preferences).and_return("user_preferences")
    end

    it "sends the expected request to the internal LLM service" do
      login_as(user)

      expected_headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-Internal-LLM-Token" => internal_llm_config["token"]
      }

      expected_system_prompt = <<~SYSTEM_PROMPT.chomp
        Suggest a list of movies that the user can watch.
        Use the English name of the movies.

        Reply with the following JSON structure:

        [
          "Movie 1",
          "Movie 2"
        ]
      SYSTEM_PROMPT

      expected_user_prompt = <<~USER_PROMPT.chomp
        Suggest me some movies based on my preferences:

        user_preferences

        I already watched these movies in the last year:

        - Inception
        - The Matrix
      USER_PROMPT

      expected_body = {
        system_prompt: expected_system_prompt,
        user_prompt: expected_user_prompt
      }

      llm_endpoint_stub = stub_request(:post, "#{internal_llm_base_url}/chat")

      get "/movies/suggestions"

      expect(response).to have_http_status(:ok)
      expect(llm_endpoint_stub.with(headers: expected_headers)).to have_been_made
      expect(llm_endpoint_stub.with(body: expected_body)).to have_been_made
    end

    context "when the LLM returns the expected response" do
      it "returns a list of suggested movies" do
        login_as(user)

        llm_response = {
          text: [
            "Suggestion 1",
            "Suggestion 2"
          ].to_json
        }

        stub_request(:post, "#{internal_llm_base_url}/chat")
          .to_return(status: 200, body: llm_response.to_json)

        get "/movies/suggestions"

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(["Suggestion 1", "Suggestion 2"])
      end
    end

    context "when the LLM returns the expected response wrapped in markdown" do
      it "returns a list of suggested movies" do
        login_as(user)

        markdown_response = <<~MARKDOWN.chomp
          ```json
          #{[
            "Suggestion 1",
            "Suggestion 2"
          ].to_json}
          ```
        MARKDOWN

        llm_response = {
          text: markdown_response
        }

        stub_request(:post, "#{internal_llm_base_url}/chat")
          .to_return(status: 200, body: llm_response.to_json)

        get "/movies/suggestions"

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(["Suggestion 1", "Suggestion 2"])
      end
    end

    context "when the returned structure is invalid" do
      it "returns an error message" do
        login_as(user)

        markdown_response = [
          {
            title: "Suggestion 1",
            description: "Description 1"
          }
        ].to_json

        llm_response = {
          text: markdown_response
        }

        stub_request(:post, "#{internal_llm_base_url}/chat")
          .to_return(status: 200, body: llm_response.to_json)

        get "/movies/suggestions"

        expect(response).to have_http_status(:service_unavailable)
        expect(response.body).to be_blank
      end
    end

    context "when the LLM returns an error" do
      it "returns an error message" do
        login_as(user)

        stub_request(:post, "#{internal_llm_base_url}/chat").to_return(status: 500)

        get "/movies/suggestions"

        expect(response).to have_http_status(:service_unavailable)
        expect(response.body).to be_blank
      end
    end
  end

  describe "DELETE #destroy" do
    it "removes a suggested movie from the cache" do
      login_as(user)

      llm_response = {
        text: [
          "Suggestion 1",
          "Suggestion 2"
        ].to_json
      }

      stub_request(:post, "#{internal_llm_base_url}/chat")
        .to_return(status: 200, body: llm_response.to_json)

      get "/movies/suggestions"

      login_as(user)
      delete "/movies/suggestions", params: { suggestion: "Suggestion 1" }

      login_as(user)
      get "/movies/suggestions"

      expect(response).to have_http_status(:ok)
      expect(json_response).to eq(["Suggestion 2"])
    end
  end

  def json_response
    @json_response ||= JSON.parse(response.body, symbolize_names: true)
  end
end
