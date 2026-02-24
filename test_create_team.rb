require './config/environment'

group = Group.find(1)

member_data = {
  "type" => "new",
  "first_name" => "ascfasdfas",
  "last_name" => "agudelo",
  "name" => "ascfasdfas agudelo",
  "email" => "jsagudgggþeloaa@gmail.com",
  "national_id" => "54564564536",
  "group" => "Thompson",
  "is_leader" => false
}

begin
  coder = Coder.create!(
    first_name: member_data["first_name"].to_s.strip,
    last_name: member_data["last_name"].to_s.strip,
    email: member_data["email"].to_s.strip.downcase.presence,
    national_id: member_data["national_id"].to_s.strip.presence,
    group: group
  )
  puts "Success: #{coder.id}"
rescue ActiveRecord::RecordInvalid => e
  puts "Validation Error: #{e.message}"
rescue => e
  puts "Other Error: #{e.class} - format #{e.message}"
end
