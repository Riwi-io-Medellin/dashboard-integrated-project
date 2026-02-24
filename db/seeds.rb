# frozen_string_literal: true

# Seed data for Dashboard Integrated Project
puts "== Seeding database =="

# Create Groups
puts "Creating groups..."
groups = [ "Thompson", "Turing", "Lovelace" ].map do |name|
  Group.find_or_create_by!(name: name)
end
puts "  Created #{groups.size} groups"

# Create Admin User
puts "Creating admin user..."
admin = User.find_or_initialize_by(email: "admin@riwi.io")
admin.assign_attributes(
  password: "Admin1234!",
  password_confirmation: "Admin1234!",
  role: "admin"
)
admin.save!
puts "  Admin: admin@riwi.io / Admin1234!"

# Create Team Leader User
puts "Creating team leader user..."
leader = User.find_or_initialize_by(email: "leader@riwi.io")
leader.assign_attributes(
  password: "Leader1234!",
  password_confirmation: "Leader1234!",
  role: "team_leader"
)
leader.save!
puts "  Team Leader: leader@riwi.io / Leader1234!"

# Create Sample Teams (EMPTY, ready for QR registration)
puts "Creating empty teams for testing..."
thompson = Group.find_by!(name: "Thompson")
turing = Group.find_by!(name: "Turing")

team1 = Team.find_or_create_by!(name: "Los Innovadores") do |t|
  t.project_category = "technology"
  t.group = thompson
end

team2 = Team.find_or_create_by!(name: "CodeBreakers") do |t|
  t.project_category = "education"
  t.group = turing
end

puts "  Created 2 empty teams ready for public registration:"
puts "  - 'Los Innovadores' Token: #{team1.token}"
puts "  - 'CodeBreakers'    Token: #{team2.token}"

puts ""
puts "== Seeding complete =="
puts "  Admin login:  admin@riwi.io / Admin1234!"
puts "  Groups: #{Group.count}"
puts "  Teams:  #{Team.count}"
puts "  Coders: 0 (Register them via public links!)"
