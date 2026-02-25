require "test_helper"

class CoderTest < ActiveSupport::TestCase
  def setup
    @group = Group.create!(name: "Test Group")
  end

  test "should be valid with valid attributes" do
    coder = Coder.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      group: @group
    )
    assert coder.valid?
  end

  test "should require first name" do
    coder = Coder.new(first_name: nil, last_name: "Doe", group: @group)
    assert_not coder.valid?
    assert_includes coder.errors[:first_name], "can't be blank"
  end

  test "should require last name" do
    coder = Coder.new(first_name: "John", last_name: nil, group: @group)
    assert_not coder.valid?
    assert_includes coder.errors[:last_name], "can't be blank"
  end

  test "should validate email format" do
    coder = Coder.new(
      first_name: "John",
      last_name: "Doe",
      email: "invalid-email",
      group: @group
    )
    assert_not coder.valid?
    assert_includes coder.errors[:email], "is invalid"
  end

  test "should allow blank email" do
    coder = Coder.new(
      first_name: "John",
      last_name: "Doe",
      email: "",
      group: @group
    )
    assert coder.valid?
  end

  test "should require unique student_id" do
    Coder.create!(
      first_name: "John",
      last_name: "Doe",
      student_id: "12345",
      group: @group
    )
    
    duplicate = Coder.new(
      first_name: "Jane",
      last_name: "Smith",
      student_id: "12345",
      group: @group
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:student_id], "has already been taken"
  end

  test "should allow nil student_id" do
    coder1 = Coder.create!(first_name: "John", last_name: "Doe", student_id: nil, group: @group)
    coder2 = Coder.create!(first_name: "Jane", last_name: "Smith", student_id: nil, group: @group)
    assert coder1.valid?
    assert coder2.valid?
  end

  test "full_name should return first and last name" do
    coder = Coder.new(first_name: "John", last_name: "Doe")
    assert_equal "John Doe", coder.full_name
  end

  test "assigned_to_team? should return false when not assigned" do
    coder = Coder.create!(first_name: "John", last_name: "Doe", group: @group)
    assert_not coder.assigned_to_team?
  end

  test "assigned_to_team? should return true when assigned" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    coder = Coder.create!(first_name: "John", last_name: "Doe", group: @group)
    TeamMember.create!(team: team, coder: coder, role: "member")
    
    assert coder.assigned_to_team?
  end

  test "should belong to group" do
    coder = Coder.create!(first_name: "John", last_name: "Doe", group: @group)
    assert_equal @group, coder.group
  end

  test "should have one team through team_member" do
    team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
    coder = Coder.create!(first_name: "John", last_name: "Doe", group: @group)
    TeamMember.create!(team: team, coder: coder, role: "member")
    
    assert_equal team, coder.team
  end

  test "should link to user after create if user exists with matching national_id" do
    user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "coder",
      document_number: "123456789"
    )
    
    coder = Coder.create!(
      first_name: "John",
      last_name: "Doe",
      national_id: "123456789",
      group: @group
    )
    
    user.reload
    assert_equal coder, user.coder
  end

  test "should link to user after create if user exists with matching email" do
    user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "coder",
      document_number: "123456789"
    )
    
    coder = Coder.create!(
      first_name: "John",
      last_name: "Doe",
      email: "test@example.com",
      group: @group
    )
    
    user.reload
    assert_equal coder, user.coder
  end
end
