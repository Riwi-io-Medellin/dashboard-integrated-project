require "test_helper"

module Admin
  class TeamsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = User.create!(
        email: "admin@test.com",
        password: "Password123!",
        password_confirmation: "Password123!",
        role: "admin",
        document_number: "123456789"
      )
      @group = Group.create!(name: "Test Group")
      @team = Team.create!(
        name: "Test Team",
        project_category: "technology",
        group: @group
      )
    end

    test "should get index" do
      sign_in @admin
      get admin_teams_url
      assert_response :success
    end

    test "should filter teams by group" do
      sign_in @admin
      other_group = Group.create!(name: "Other Group")
      other_team = Team.create!(
        name: "Other Team",
        project_category: "education",
        group: other_group
      )

      get admin_teams_url(group_id: @group.id)
      assert_response :success
    end

    test "should show team" do
      sign_in @admin
      get admin_team_url(@team)
      assert_response :success
    end

    test "should get new" do
      sign_in @admin
      get new_admin_team_url
      assert_response :success
    end

    test "should create team" do
      sign_in @admin
      assert_difference "Team.count", 1 do
        post admin_teams_url, params: {
          team: {
            name: "New Team",
            project_category: "education",
            group_id: @group.id
          }
        }
      end

      assert_redirected_to admin_team_path(Team.last)
    end

    test "should not create team with invalid params" do
      sign_in @admin
      assert_no_difference "Team.count" do
        post admin_teams_url, params: {
          team: {
            name: "",
            project_category: "invalid",
            group_id: @group.id
          }
        }
      end

      assert_response :unprocessable_entity
    end

    test "should get qr code page" do
      sign_in @admin
      get qr_admin_team_url(@team)
      assert_response :success
    end

    test "should require authentication" do
      get admin_teams_url
      assert_redirected_to new_user_session_path
    end
  end
end
