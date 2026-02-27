# frozen_string_literal: true

# Group represents a classroom/cohort of coders (e.g., "Thompson", "Turing")
class Group < ApplicationRecord
  has_many :coders, dependent: :destroy
  has_many :teams, dependent: :destroy

  JORNADAS = %w[AM PM].freeze

  validates :name, presence: true, uniqueness: true
  validates :jornada, inclusion: { in: JORNADAS }, allow_blank: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
