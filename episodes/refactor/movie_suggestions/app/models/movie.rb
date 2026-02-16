class Movie < ApplicationRecord
  enum :genre, {
    action: "ACTION",
    comedy: "COMEDY",
    drama: "DRAMA",
    horror: "HORROR",
    sci_fi: "SCI_FI",
    other: "OTHER"
  }
end

# == Schema Information
#
# Table name: movies
#
#  id         :integer          not null, primary key
#  genre      :string           not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
