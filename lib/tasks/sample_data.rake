
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_relationships
    make_emails
  end

  task input_populate: :environment do
    puts "Enter the number of users you would like to create"
    print "> "
    n_users = STDIN.gets.to_i

    puts "Enter max possible number of subscribers for each user"
    print "> "
    n_subscribers = STDIN.gets.to_i

    puts "Enter max possible number of emails sent from user"
    print "> "
    n_emails = STDIN.gets.to_i
    
    make_users(n_users)
    make_relationships(n_subscribers)
    make_emails(n_emails)
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


def make_users(number = 20)
  puts "Creating Admin User..."
  admin = User.create!(name:     "Administrator",
                       email:    "admin@email.com",
                       password: "foobar",
                       password_confirmation: "foobar",
                       email_notify: false,
                       forward: true)
  admin.toggle!(:confirmed)
  admin.toggle!(:admin)
  puts "Creating #{number - 1} other users..."
  (number - 1).times do |n|
    name  = Faker::Name.name
    email = "example#{n+1}@nonexistent.tt"
    password  = "password"
    u = User.create!(name:     name,
                     email:    email,
                     password: password,
                     password_confirmation: password,
                     email_notify: true,
                     forward: true )
    u.toggle!(:confirmed)
    u.likes = rand(25..200) and u.save
  end
end

def make_relationships(n = 10)
  number = n > User.count ? User.count : n
  puts "Creating subscribers... " 
  users = User.all

  users.each do |user|
    n_subscribers = rand(1..number)
    puts "Creating #{n_subscribers} for User #{user.id}"
    subscribers = users[0..n_subscribers]
    subscribers.each { |subscriber| user.add_subscriber!(subscriber) unless subscriber.id == user.id }
  end
end

def make_emails(num = 20)
  puts "Creating Emails with WRLog entries..." 
  users = User.all

  users.each do |user|
    subscribers = user.subscribers
    n_emails = rand(2..num)
    puts "Creating #{n_emails} for User #{user.id}"
    n_emails.times do |n|
      body =  Faker::Lorem.paragraph
      email = user.emails.create!(to: "subscribed@worth-reading.org",
                                  from: user.email, 
                                  subject: "Message  #{n}",
                                  body: body,
                                  parts: [body])

      subscribers[0..rand(1..subscribers.count)].each do |recipient|  # How many subscribers today?
        wr_log = email.wr_logs.create(email_id: email.id, sender_id: user.id, receiver_id:recipient.id)
        wr_log.emailed = DateTime.now + rand(0..3)

        if rand(0..1.0) > 0.40 # Did he open it?
          wr_log.opened = wr_log.emailed + rand(0..3)
        end

        if (rand(0..1.0) > 0.60)  # Did he like it ?
          if wr_log.opened  # Did he enable graphics?
            wr_log.worth_reading = wr_log.opened + rand(0..5)
          else
            wr_log.worth_reading = wr_log.emailed + rand(0..3)
          end         
        end
        wr_log.save        
      end
    end 
  end
end
