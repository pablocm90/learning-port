# Create admin writer if none exists
Writer.find_or_create_by!(email: 'admin@example.com') do |writer|
  writer.name = 'Pablo'
  writer.password = 'changeme123'
  writer.bio = 'Software developer and lifelong learner.'
end

puts "Admin writer created: admin@example.com / changeme123"
