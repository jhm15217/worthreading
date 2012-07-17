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
  admin.toggle!(:admin)
  puts "Creating 99 other users..."
  99.times do |n|
    name  = Faker::Name.name
    email = "example#{n+1}@helloworld.org"
    password  = "password"
    User.create!(name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_relationships
  puts "Creating subscribers... " 
  users = User.all

  users[0..25].each do |user|
    n = user.id + 1
    subscribers = users[n..30]
    subscribers.each { |subscriber| user.add_subscriber!(subscriber) }
  end
end

def make_emails
  puts "Creating Emails..." 
  users = User.all

  users[0..25].each do |user|
    rand(1...25).times.each do |n|
      user.emails.create(to: "mailinglist@worthreading.org", 
                       from: user.email, 
                       subject: "HelloWorld #{n}",
                       body: Faker::Lorem.paragraph)
    end
  end
end
