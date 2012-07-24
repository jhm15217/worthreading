FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"
    confirmed true

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
      sit amet metus neque.} 
  end
end
