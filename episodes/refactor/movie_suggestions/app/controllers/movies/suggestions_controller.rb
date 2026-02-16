class Movies::SuggestionsController < ApplicationController
  # GET /movies/suggestions
  def index
    watched_movies = current_user.watched_movies
                                 .where("watched_at > ?", 1.year.ago)
                                 .pluck(:title)
    service = Movies::SuggestedMoviesService.new
    suggestions = service.suggest_movies(current_user, watched_movies, I18n.locale)

    if service.error.blank?
      render json: suggestions, status: :ok
    else
      head :service_unavailable
    end
  end

  # DELETE /movies/suggestions?movie=movie_name
  def destroy
    service = Movies::SuggestedMoviesService.new
    service.remove_suggested_movie(params[:suggestion], I18n.locale)
    head :ok
  end
end
