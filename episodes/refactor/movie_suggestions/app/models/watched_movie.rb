class WatchedMovie < ApplicationRecord
  belongs_to :user
  belongs_to :movie
end

# == Schema Information
#
# Table name: watched_movies
#
#  id         :integer          not null, primary key
#  watched_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  movie_id   :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_watched_movies_on_movie_id  (movie_id)
#  index_watched_movies_on_user_id   (user_id)
#
# Foreign Keys
#
#  movie_id  (movie_id => movies.id)
#  user_id   (user_id => users.id)
#
