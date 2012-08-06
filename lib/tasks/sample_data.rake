
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
  admin = User.create!(name:     "Administrator",
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
    subscribers = user.subscribers
    (0..rand(0..50)).to_a.each do |n|
      email = user.emails.create!(to: "subscribed@worth-reading.org",
                                  from: user.email, 
                                  subject: "Message  #{n}",
                                  body: Faker::Lorem.paragraph)

      subscribers[0..rand(1..subscribers.count)].each do |recipient|  # How many subscribers today?
        wr_log = email.wr_logs.create(email_id: email.id, sender_id: user.id, receiver_id:recipient.id)
        wr_log.emailed = DateTime.now + rand(0..3.days)

        if rand(0..1.0) > 0.60 # Did he open it?
          wr_log.opened = wr_log.emailed + rand(0.seconds..3.days)
        end

        if (rand(0..1.0) > 0.80)  # Did he like it ?
          if wr_log.opened  # Did he enable graphics?
            wr_log.worth_reading = wr_log.opened + rand(0.seconds..5.minutes)
          else
            wr_log.worth_reading = wr_log.emailed + rand(0.seconds..3.0.days)
          end         
        end
        wr_log.save        
      end
    end 
  end
end
