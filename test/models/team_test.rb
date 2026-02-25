require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def setup
    @group = Group.create!(name: "Test Group")
  end

  test "should be valid with valid attributes" do
    team = Team.new(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert team.valid?
  end

  test "should require name" do
    team = Team.new(name: nil, project_category: "technology", group: @group)
    assert_not team.valid?
    assert_includes team.errors[:name], "can't be blank"
  end

  test "should require project_category" do
    team = Team.new(name: "Test Team", project_category: nil, group: @group)
    assert_not team.valid?
  end

  test "should validate project_category inclusion" do
    team = Team.new(
      name: "Test Team",
      project_category: "invalid_category",
      group: @group
    )
    assert_not team.valid?
    assert_includes team.errors[:project_category], "is not included in the list"
  end

  test "should accept valid project categories" do
    Team::CATEGORIES.each do |category|
      team = Team.new(
        name: "Test Team #{category}",
        project_category: category,
        group: @group
      )
      assert team.valid?, "#{category} should be a valid category"
    end
  end

  test "should generate token on create" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert_not_nil team.token
    assert team.token.length > 0
  end

  test "should require unique token" do
    team1 = Team.create!(
      name: "Team 1",
      project_category: "technology",
      group: @group
    )

    team2 = Team.new(
      name: "Team 2",
      project_category: "education",
      group: @group,
      token: team1.token
    )
    assert_not team2.valid?
    assert_includes team2.errors[:token], "has already been taken"
  end

  test "should belong to group" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert_equal @group, team.group
  end

  test "should have many team_members" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert_respond_to team, :team_members
  end

  test "should have many coders through team_members" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert_respond_to team, :coders
  end

  test "should destroy dependent team_members when destroyed" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    coder = Coder.create!(first_name: "John", last_name: "Doe", group: @group)
    TeamMember.create!(team: team, coder: coder, role: "member")

    assert_difference "TeamMember.count", -1 do
      team.destroy
    end
  end

  test "validate_member_count should fail with less than 3 members" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )

    2.times do |i|
      coder = Coder.create!(first_name: "Coder", last_name: "#{i}", group: @group)
      TeamMember.create!(team: team, coder: coder, role: "member")
    end

    assert_not team.valid?(:registration)
    assert_includes team.errors[:base], "El equipo debe tener al menos 3 miembros"
  end

  test "validate_member_count should pass with 3 to 6 members" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )

    3.times do |i|
      coder = Coder.create!(first_name: "Coder", last_name: "#{i}", group: @group)
      TeamMember.create!(team: team, coder: coder, role: "member")
    end

    assert team.valid?(:registration)
  end

  test "validate_member_count should fail with more than 6 members" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )

    7.times do |i|
      coder = Coder.create!(first_name: "Coder", last_name: "#{i}", group: @group)
      TeamMember.create!(team: team, coder: coder, role: "member")
    end

    assert_not team.valid?(:registration)
    assert_includes team.errors[:base], "El equipo no puede tener más de 6 miembros"
  end

  test "leader should return the team leader coder" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    leader_coder = Coder.create!(first_name: "Leader", last_name: "Coder", group: @group)
    member_coder = Coder.create!(first_name: "Member", last_name: "Coder", group: @group)

    TeamMember.create!(team: team, coder: leader_coder, role: "leader")
    TeamMember.create!(team: team, coder: member_coder, role: "member")

    assert_equal leader_coder, team.leader
  end

  test "category_label should return human-readable label" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert_equal "Tecnología", team.category_label
  end

  test "needs_openai_api should default to false" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    assert_equal false, team.needs_openai_api
  end
end
