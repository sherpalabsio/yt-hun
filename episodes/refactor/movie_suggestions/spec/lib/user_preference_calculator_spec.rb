# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPreferenceCalculator do
  describe "for action genre" do
    it "works" do
      allow_any_instance_of(Object).to receive(:rand).and_return(0)

      user = User.new(birthdate: Date.new(1990, 12, 1))
      actual = described_class.new(user).calculate_preferences

      expect(actual).to include("My mood for action: 12/10")
    end
  end
end
