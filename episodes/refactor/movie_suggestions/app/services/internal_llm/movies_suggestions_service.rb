class InternalLlm::MoviesSuggestionsService < InternalLlm::BaseService
  SYSTEM_PROMPT = <<~TEXT.chomp
    Suggest a list of movies that the user can watch.
    Use the {{LANGUAGE}} name of the movies.

    Reply with the following JSON structure:

    [
      "Movie 1",
      "Movie 2"
    ]
  TEXT

  def call(watched_movies, user, language)
    language_name = I18n.t("languages.#{language}", locale: :en)
    body = {
      system_prompt: SYSTEM_PROMPT.gsub("{{LANGUAGE}}", language_name),
      user_prompt: <<~HERE.chomp
        Suggest me some movies based on my preferences:

        #{UserPreferenceCalculator.new(user).calculate_preferences}

        I already watched these movies in the last year:

        #{watched_movies.map { |movie| "- #{movie}" }.join("\n")}
      HERE
    }
    send_request_and_capture_errors("chat", method: :post, body: body.to_json)
  end
end
