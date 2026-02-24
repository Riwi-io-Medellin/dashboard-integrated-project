# frozen_string_literal: true

# Group represents a classroom/cohort of coders (e.g., "Thompson", "Turing")
class Group < ApplicationRecord
  has_many :coders, dependent: :destroy
  has_many :teams, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
