
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_relationships
    make_emails
  end
  
  task create_users: :environment do
    make_users
  end

  task create_subscribers: :environment do
    make_relationships
  end

  task create_emails: :environment do
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
  puts "Creating 19 other users..."
  19.times do |n|
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

  users.each do |user|
    n_subscribers = rand(1..10)
    subscribers = users[0..n_subscribers]
    subscribers.each { |subscriber| user.add_subscriber!(subscriber) unless subscriber.id == user.id }
  end
end

def make_emails
  puts "Creating Emails with WRLog entries..." 
  users = User.all

  users.each do |user|
    subscribers = user.subscribers
    rand(2..20).times do |n|
      puts "Creating Email #{n} for #{user.name}"
      email = user.emails.create!(to: "subscribed@worth-reading.org",
                                  from: user.email, 
                                  subject: "Message  #{n}",
                                  body: Faker::Lorem.paragraph)

      subscribers[0..rand(1..subscribers.count)].each do |recipient|  # How many subscribers today?
        wr_log = email.wr_logs.create(email_id: email.id, sender_id: user.id, receiver_id:recipient.id)
        wr_log.emailed = DateTime.now + rand(0..3)
        puts "Emailed:#{wr_log.emailed}"

        if rand(0..1.0) > 0.40 # Did he open it?
          wr_log.opened = wr_log.emailed + rand(0..3)
        end
        puts "Opened: #{wr_log.opened}"

        if (rand(0..1.0) > 0.60)  # Did he like it ?
          if wr_log.opened  # Did he enable graphics?
            wr_log.worth_reading = wr_log.opened + rand(0..5)
          else
            wr_log.worth_reading = wr_log.emailed + rand(0..3)
          end         
        end
        puts "WorthReading: #{wr_log.worth_reading}"
        puts ""
        wr_log.save        
      end
    end 
  end
end
