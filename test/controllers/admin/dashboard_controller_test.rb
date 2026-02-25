require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = User.create!(
        email: "admin@test.com",
        password: "Password123!",
        password_confirmation: "Password123!",
        role: "admin",
        document_number: "123456789"
      )
    end

    test "should get index" do
      sign_in @admin
      get admin_root_url
      assert_response :success
    end

    test "should display statistics" do
      sign_in @admin
      group = Group.create!(name: "Test Group")
      team = Team.create!(
        name: "Test Team",
        project_category: "technology",
        group: group
      )
      coder = Coder.create!(
        first_name: "John",
        last_name: "Doe",
        group: group
      )

      get admin_root_url
      assert_response :success
    end

    test "should require authentication" do
      get admin_root_url
      assert_redirected_to new_user_session_path
    end

    test "should require admin or team_leader role" do
      coder_user = User.create!(
        email: "coder@test.com",
        password: "Password123!",
        password_confirmation: "Password123!",
        role: "coder",
        document_number: "987654321"
      )
      sign_in coder_user

      get admin_dashboard_url
      assert_redirected_to root_path
    end

    test "should allow team_leader access" do
      team_leader = User.create!(
        email: "leader@test.com",
        password: "Password123!",
        password_confirmation: "Password123!",
        role: "team_leader",
        document_number: "987654321"
      )
      sign_in team_leader

      get admin_dashboard_url
      assert_response :success
    end
  end
end
