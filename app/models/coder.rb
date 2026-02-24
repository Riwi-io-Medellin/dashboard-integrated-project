# frozen_string_literal: true

# Coder represents a RIWI student enrolled in a training group
class Coder < ApplicationRecord
  belongs_to :group, optional: true
  has_one :team_member, dependent: :destroy
  has_one :team, through: :team_member
  has_one :user, dependent: :nullify

  validates :first_name, :last_name, presence: true
  validates :student_id, uniqueness: true, allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Full name helper
  def full_name
    "#{first_name} #{last_name}"
  end

  # Check if coder is already assigned to a team
  def assigned_to_team?
    team_member.present?
  end
  after_create :link_to_user

  private

  def link_to_user
    found_user = User.find_by(document_number: national_id) if national_id.present?
    found_user ||= User.find_by(email: email)

    found_user.update(coder: self) if found_user && found_user.coder_id.nil?
  end
end
