
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_relationships
    make_emails
  end
end

def make_users
  puts "Creating Admin User..."
  admin = User.create!(name:     "Example User",
                       email:    "admin@email.com",
                       password: "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:confirmed)
  admin.toggle!(:admin)
  puts "Creating 99 other users..."
  99.times do |n|
    name  = Faker::Name.name
    email = "example#{n+1}@worth-reading.org"
    password  = "password"
    u = User.create!(name:     name,
                     email:    email,
                     password: password,
                     password_confirmation: password)
    u.toggle!(:confirmed)
    u.likes = rand(25..200) and u.save
  end
end

def make_relationships
  puts "Creating subscribers... " 
  users = User.all

  users[0..25].each do |user|
    n_subscribers = rand(5..75)
    subscribers = users[0..n_subscribers]
    subscribers.each { |subscriber| user.add_subscriber!(subscriber) unless subscriber.id == user.id }
  end
end

def make_emails
  puts "Creating Emails with WRLog entries..." 
  users = User.all

  users[0..25].each do |user|
    rand(15..40).times.each do |n|
      recipient = users[rand(5..30)]
      email = user.emails.create(to: recipient.email, 
                         from: user.email, 
                         subject: "HelloWorld #{n}",
                         body: Faker::Lorem.paragraph)
      wr_log = email.wr_logs.create(action:"email", sender_id:user.id,
                      receiver_id:recipient.id, email_part: 0, responded: false)
    end
  end

end
