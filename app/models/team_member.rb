# frozen_string_literal: true

# TeamMember is the join table between Team and Coder
# Role can be "leader" or "member"
class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :coder

  ROLES = %w[leader member].freeze

  validates :role, inclusion: { in: ROLES }
  validates :coder_id, uniqueness: { message: "ya pertenece a otro equipo" }
end
