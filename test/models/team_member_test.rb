require "test_helper"

class TeamMemberTest < ActiveSupport::TestCase
  def setup
    @group = Group.create!(name: "Test Group")
    @team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    @coder = Coder.create!(first_name: "John", last_name: "Doe", group: @group)
  end

  test "should be valid with valid attributes" do
    team_member = TeamMember.new(
      team: @team,
      coder: @coder,
      role: "member"
    )
    assert team_member.valid?
  end

  test "should require team" do
    team_member = TeamMember.new(coder: @coder, role: "member")
    assert_not team_member.valid?
  end

  test "should require coder" do
    team_member = TeamMember.new(team: @team, role: "member")
    assert_not team_member.valid?
  end

  test "should require role" do
    team_member = TeamMember.new(team: @team, coder: @coder, role: nil)
    assert_not team_member.valid?
  end

  test "should validate role inclusion" do
    team_member = TeamMember.new(
      team: @team,
      coder: @coder,
      role: "invalid_role"
    )
    assert_not team_member.valid?
    assert_includes team_member.errors[:role], "is not included in the list"
  end

  test "should accept leader role" do
    team_member = TeamMember.new(
      team: @team,
      coder: @coder,
      role: "leader"
    )
    assert team_member.valid?
  end

  test "should accept member role" do
    team_member = TeamMember.new(
      team: @team,
      coder: @coder,
      role: "member"
    )
    assert team_member.valid?
  end

  test "should require unique coder_id" do
    TeamMember.create!(team: @team, coder: @coder, role: "member")

    another_team = Team.create!(
      name: "Another Team",
      project_category: "education",
      group: @group
    )

    duplicate = TeamMember.new(
      team: another_team,
      coder: @coder,
      role: "member"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:coder_id], "ya pertenece a otro equipo"
  end

  test "should belong to team" do
    team_member = TeamMember.create!(
      team: @team,
      coder: @coder,
      role: "member"
    )
    assert_equal @team, team_member.team
  end

  test "should belong to coder" do
    team_member = TeamMember.create!(
      team: @team,
      coder: @coder,
      role: "member"
    )
    assert_equal @coder, team_member.coder
  end
end
