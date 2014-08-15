# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  fb_uid                 :string(255)
#  fb_token               :string(255)
#  fb_token_expiration    :datetime
#  username               :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :base_user, class: User do
    username "base_user"
    email "base_user@email.com"
    password "base_user_password"
  end

  factory :user do
    username "username"
    email "user@email.com"
    password "user_password"
    # confirmed_at Time.now()

    factory :invalid_user do


    end
  end

  factory :admin, class: User do
    email "admin@email.com"
    password "admin_password"
    username "admin"
  end



end

