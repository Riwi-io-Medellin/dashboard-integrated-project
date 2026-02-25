require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    group = Group.new(name: "Test Group")
    assert group.valid?
  end

  test "should require name" do
    group = Group.new(name: nil)
    assert_not group.valid?
    assert_includes group.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    Group.create!(name: "Unique Group")
    duplicate_group = Group.new(name: "Unique Group")
    assert_not duplicate_group.valid?
    assert_includes duplicate_group.errors[:name], "has already been taken"
  end

  test "should have many coders" do
    group = Group.create!(name: "Test Group")
    assert_respond_to group, :coders
  end

  test "should have many teams" do
    group = Group.create!(name: "Test Group")
    assert_respond_to group, :teams
  end

  test "should destroy dependent coders when destroyed" do
    group = Group.create!(name: "Test Group")
    coder = Coder.create!(
      first_name: "John",
      last_name: "Doe",
      group: group
    )

    assert_difference "Coder.count", -1 do
      group.destroy
    end
  end

  test "should destroy dependent teams when destroyed" do
    group = Group.create!(name: "Test Group")
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: group
    )

    assert_difference "Team.count", -1 do
      group.destroy
    end
  end
end
