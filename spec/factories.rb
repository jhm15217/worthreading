FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"
    confirmed true
    email_notify true
    forward true
    first_login_at Time.now

    factory :admin do
      admin true
    end
  end

  factory :email do 
    sequence(:to)  { |n| "someone_#{n}@email.com"}
    sequence(:from)  { |n| "someone_#{n+1}@email.com"}
    subject "Nothing"
    body  %Q{Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam 
      sed ligula a orci gravida ornare. In laoreet orci sit amet lorem eleifend 
      pharetra. Nunc interdum eros in magna condimentum dignissim. Suspendisse 
      sit amet metus neque.
      <more>} 
  end

  factory :wr_log do
    action "email"
    sequence(:sender_id) { |n| n }
    sequence(:receiver_id) { |n| n+1 }
    sequence(:email_id) {|n| n }
    email_part 1
  end
end
