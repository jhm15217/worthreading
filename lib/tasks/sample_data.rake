namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_relationships
  end
end

def make_users
  puts "Creating Admin User..."
  admin = User.create!(name:     "Example User",
                       email:    "example@railstutorial.org",
                       password: "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:admin)
  puts "Creating 99 other users..."
  99.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_relationships
  puts "Creating subscribers for Users 1, 2 and 3"
  users = User.all
  u1 = users.first
  u2 = users[2]
  u3 = users[3] 
  u1_subscribers = users[2..10]
  u2_subcribers = users[3..15]
  u3_subscribers = users[4..25]
end

def make_emails
