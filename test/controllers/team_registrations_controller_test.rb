require "test_helper"

class TeamRegistrationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @group = Group.create!(name: "Test Group")
    @team = Team.create!(
      name: "Test Team",
      project_category: "technology",
      group: @group
    )
  end

  test "should get new registration page" do
    get team_registration_url(token: @team.token)
    assert_response :success
  end

  test "should show already registered page if team is registered" do
    @team.update!(registered_at: Time.current)
    get team_registration_url(token: @team.token)
    assert_response :success
    assert_select "h1", text: "Equipo Ya Registrado"
  end

  test "should create team registration with valid data" do
    members_data = [
      {
        type: "new",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        is_leader: true
      },
      {
        type: "new",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        is_leader: false
      },
      {
        type: "new",
        first_name: "Bob",
        last_name: "Johnson",
        email: "bob@example.com",
        is_leader: false
      }
    ]

    assert_difference "Coder.count", 3 do
      assert_difference "TeamMember.count", 3 do
        post team_registration_url(token: @team.token), params: {
          team_name: "New Team Name",
          project_category: "education",
          members_data: members_data.to_json
        }
      end
    end

    assert_redirected_to team_registration_path(token: @team.token)
    @team.reload
    assert_equal "New Team Name", @team.name
    assert_equal "education", @team.project_category
    assert_not_nil @team.registered_at
  end

  test "should reject registration with less than 3 members" do
    members_data = [
      {
        type: "new",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        is_leader: true
      },
      {
        type: "new",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        is_leader: false
      }
    ]

    assert_no_difference "Coder.count" do
      post team_registration_url(token: @team.token), params: {
        team_name: "New Team",
        project_category: "education",
        members_data: members_data.to_json
      }
    end

    assert_response :unprocessable_entity
  end

  test "should reject registration with more than 6 members" do
    members_data = 7.times.map do |i|
      {
        type: "new",
        first_name: "Member",
        last_name: "#{i}",
        email: "member#{i}@example.com",
        is_leader: i == 0
      }
    end

    assert_no_difference "Coder.count" do
      post team_registration_url(token: @team.token), params: {
        team_name: "New Team",
        project_category: "education",
        members_data: members_data.to_json
      }
    end

    assert_response :unprocessable_entity
  end

  test "should reject registration without leader" do
    members_data = [
      {
        type: "new",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        is_leader: false
      },
      {
        type: "new",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        is_leader: false
      },
      {
        type: "new",
        first_name: "Bob",
        last_name: "Johnson",
        email: "bob@example.com",
        is_leader: false
      }
    ]

    assert_no_difference "Coder.count" do
      post team_registration_url(token: @team.token), params: {
        team_name: "New Team",
        project_category: "education",
        members_data: members_data.to_json
      }
    end

    assert_response :unprocessable_entity
  end

  test "should reject registration with blank team name" do
    members_data = [
      {
        type: "new",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        is_leader: true
      },
      {
        type: "new",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        is_leader: false
      },
      {
        type: "new",
        first_name: "Bob",
        last_name: "Johnson",
        email: "bob@example.com",
        is_leader: false
      }
    ]

    assert_no_difference "Coder.count" do
      post team_registration_url(token: @team.token), params: {
        team_name: "",
        project_category: "education",
        members_data: members_data.to_json
      }
    end

    assert_response :unprocessable_entity
  end

  test "should reject registration with invalid category" do
    members_data = [
      {
        type: "new",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        is_leader: true
      },
      {
        type: "new",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        is_leader: false
      },
      {
        type: "new",
        first_name: "Bob",
        last_name: "Johnson",
        email: "bob@example.com",
        is_leader: false
      }
    ]

    assert_no_difference "Coder.count" do
      post team_registration_url(token: @team.token), params: {
        team_name: "New Team",
        project_category: "invalid_category",
        members_data: members_data.to_json
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle existing coder in registration" do
    existing_coder = Coder.create!(
      first_name: "Existing",
      last_name: "Coder",
      email: "existing@example.com",
      group: @group
    )

    members_data = [
      {
        type: "existing",
        coder_id: existing_coder.id,
        is_leader: true
      },
      {
        type: "new",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        is_leader: false
      },
      {
        type: "new",
        first_name: "Bob",
        last_name: "Johnson",
        email: "bob@example.com",
        is_leader: false
      }
    ]

    assert_difference "Coder.count", 2 do
      assert_difference "TeamMember.count", 3 do
        post team_registration_url(token: @team.token), params: {
          team_name: "Mixed Team",
          project_category: "education",
          members_data: members_data.to_json
        }
      end
    end

    assert_redirected_to team_registration_path(token: @team.token)
  end
end
