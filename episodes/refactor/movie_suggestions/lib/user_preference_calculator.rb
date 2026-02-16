class UserPreferenceCalculator
  EXTRA = [
    { action: 1, comedy: 1, drama: 1 },
    { action: 2, comedy: 2, drama: 2 },
    { action: 3, comedy: 3, drama: 3 },
    { action: 4, comedy: 4, drama: 4 },
    { action: 5, comedy: 5, drama: 5 },
    { action: 6, comedy: 6, drama: 6 },
    { action: 7, comedy: 7, drama: 7 },
    { action: 8, comedy: 8, drama: 8 },
    { action: 9, comedy: 9, drama: 9 },
    { action: 10, comedy: 10, drama: 10 },
    { action: 11, comedy: 11, drama: 11 },
    { action: 12, comedy: 12, drama: 12 }
  ]

  def initialize(user)
    @user = user
  end

  def calculate_preferences
    sleep 1 # Simulate a time-consuming calculation

    genres = @user.watched_movies.where("watched_at > ?", 1.year.ago).pluck(:genre)

    <<~PREFERENCES
      My mood for action: #{rand(0..5) - genres.count("ACTION") + EXTRA[@user.birthdate.month - 1][:action]}/10
      My mood for comedy: #{rand(0..2) - genres.count("COMEDY") + EXTRA[@user.birthdate.month - 1][:comedy]}/10
      My mood for drama: #{rand(0..3) - genres.count("DRAMA") + EXTRA[@user.birthdate.month - 1][:drama]}/10
      My mood for horror: #{rand(0..10) - genres.count("HORROR")}/10
    PREFERENCES
  end
end
