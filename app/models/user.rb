# frozen_string_literal: true

# User model for authentication via Devise
# Roles: admin, team_leader, coder
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :coder, optional: true

  ROLES = %w[admin team_leader coder].freeze

  validates :role, inclusion: { in: ROLES }
  validates :document_number, presence: true, numericality: { only_integer: true }

  def admin?
    role == "admin"
  end

  def team_leader?
    role == "team_leader"
  end

  def coder?
    role == "coder"
  end
  before_validation :link_to_coder, on: :create

  private

  def link_to_coder
    return if coder_id.present?

    found_coder = Coder.find_by(national_id: document_number) if document_number.present?
    found_coder ||= Coder.find_by(email: email)

    self.coder = found_coder if found_coder
  end
end
