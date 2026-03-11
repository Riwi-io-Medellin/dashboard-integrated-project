# frozen_string_literal: true

# Team represents a group of 3-5 coders working on an integrated project
class Team < ApplicationRecord
  belongs_to :group
  belongs_to :created_by_user, class_name: "User", optional: true
  has_many :team_members, dependent: :destroy
  has_many :coders, through: :team_members

  CATEGORIES = %w[sports ecommerce education health technology tourism housing riwi_case].freeze

  CATEGORY_LABELS = {
    "sports" => "Deportes",
    "ecommerce" => "E-Commerce",
    "education" => "Educación",
    "health" => "Salud",
    "technology" => "Tecnología",
    "tourism" => "Turismo",
    "housing" => "Vivienda",
    "riwi_case" => "Caso RIWI"
  }.freeze

  validates :name, presence: true
  validates :description, presence: true
  validates :project_category, inclusion: { in: CATEGORIES }
  validates :token, presence: true, uniqueness: true

  # Whether the team's project will use OpenAI API
  attribute :needs_openai_api, :boolean, default: false
  validate :validate_member_count, on: :registration

  before_validation :generate_token, on: :create

  # Team must have between 3 and 5 members (max 6 for fusion)
  def validate_member_count
    if team_members.size < 3
      errors.add(:base, "El equipo debe tener al menos 3 miembros")
    elsif team_members.size > 6
      errors.add(:base, "El equipo no puede tener más de 6 miembros")
    end
  end

  # Get the team leader
  def leader
    team_members.find_by(role: "leader")&.coder
  end

  # Human-readable category label
  def category_label
    CATEGORY_LABELS[project_category] || project_category
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16) if token.blank?
  end
end
