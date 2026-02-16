class Movies::SuggestedMoviesService
  CACHE_KEY_PREFIX = "/movies/movies_suggestions"
  CACHE_EXPIRY_TIME = 1.hour

  attr_reader :error

  def suggest_movies(user, watched_movies, language)
    llm_service = InternalLlm::MoviesSuggestionsService.new

    cache_key = "#{CACHE_KEY_PREFIX}/#{language}"
    entry = Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY_TIME) do
      response = llm_service.call(watched_movies, user, language)

      @error = llm_service.error
      return nil if llm_service.error || response["text"].blank?

      output = if response["text"].starts_with?("```json")
                 response["text"][7..-4]
               else
                 response["text"]
               end

      result = JSON.parse(output)
      if result.is_a?(Array) && result.all? { |it| it.is_a?(String) }
        result
      else
        @error = "Internal LLM service returned incorrect JSON structure"
        Rails.logger.error @error
        nil
      end
    rescue JSON::ParserError
      @error = "Internal LLM service returned invalid JSON"
      Rails.logger.error @error
      nil
    end

    # To trigger recompute for the next fetch
    Rails.cache.delete(cache_key) if entry.blank?

    entry
  end

  def remove_suggested_movie(suggestion, language)
    return unless suggestion

    cache_key = "#{CACHE_KEY_PREFIX}/#{language}"
    entry = Rails.cache.read(cache_key)
    entry = entry.present? ? entry - [suggestion] : nil

    if entry.blank?
      # To trigger recompute for the next fetch
      Rails.cache.delete(cache_key)
    else
      Rails.cache.write(cache_key, entry, expires_in: CACHE_EXPIRY_TIME)
    end
  end
end
