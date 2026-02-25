require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "admin",
      document_number: "123456789"
    )
    assert user.valid?
  end

  test "should require email" do
    user = User.new(
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "admin",
      document_number: "123456789"
    )
    assert_not user.valid?
  end

  test "should require password" do
    user = User.new(
      email: "test@example.com",
      role: "admin",
      document_number: "123456789"
    )
    assert_not user.valid?
  end

  test "should have default role of coder" do
    user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      document_number: "123456789"
    )
    assert_equal "coder", user.role
  end

  test "should validate role inclusion" do
    user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "invalid_role",
      document_number: "123456789"
    )
    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end

  test "should accept admin role" do
    user = User.new(
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "admin",
      document_number: "123456789"
    )
    assert user.valid?
  end

  test "should accept team_leader role" do
    user = User.new(
      email: "leader@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "team_leader",
      document_number: "123456789"
    )
    assert user.valid?
  end

  test "should accept coder role" do
    user = User.new(
      email: "coder@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "coder",
      document_number: "123456789"
    )
    assert user.valid?
  end

  test "should require document_number" do
    user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "admin"
    )
    assert_not user.valid?
    assert_includes user.errors[:document_number], "can't be blank"
  end

  test "should require numeric document_number" do
    user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "admin",
      document_number: "abc123"
    )
    assert_not user.valid?
    assert_includes user.errors[:document_number], "is not a number"
  end

  test "admin? should return true for admin role" do
    user = User.new(role: "admin")
    assert user.admin?
  end

  test "admin? should return false for non-admin role" do
    user = User.new(role: "coder")
    assert_not user.admin?
  end

  test "team_leader? should return true for team_leader role" do
    user = User.new(role: "team_leader")
    assert user.team_leader?
  end

  test "team_leader? should return false for non-team_leader role" do
    user = User.new(role: "admin")
    assert_not user.team_leader?
  end

  test "coder? should return true for coder role" do
    user = User.new(role: "coder")
    assert user.coder?
  end

  test "coder? should return false for non-coder role" do
    user = User.new(role: "admin")
    assert_not user.coder?
  end

  test "should link to coder on create if coder exists with matching national_id" do
    group = Group.create!(name: "Test Group")
    coder = Coder.create!(
      first_name: "John",
      last_name: "Doe",
      national_id: "123456789",
      group: group
    )
    
    user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "coder",
      document_number: "123456789"
    )
    
    assert_equal coder, user.coder
  end

  test "should link to coder on create if coder exists with matching email" do
    group = Group.create!(name: "Test Group")
    coder = Coder.create!(
      first_name: "John",
      last_name: "Doe",
      email: "test@example.com",
      group: group
    )
    
    user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "coder",
      document_number: "123456789"
    )
    
    assert_equal coder, user.coder
  end

  test "should belong to coder optionally" do
    user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "admin",
      document_number: "123456789"
    )
    assert_nil user.coder
  end
end
