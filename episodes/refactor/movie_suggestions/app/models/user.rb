class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  has_many :watched_movies_association, class_name: "WatchedMovie"
  has_many :watched_movies, through: :watched_movies_association, source: :movie
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  birthdate          :date             not null
#  email              :string           not null
#  encrypted_password :string           not null
#  name               :string           not null
#  settings           :json             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
