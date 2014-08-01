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

require 'rails_helper'

describe User do
  
  before do
    @base_user = FactoryGirl.build(:base_user)
  end


  context "model" do
    subject { @base_user }
    it { should respond_to(:username) }
    it { should respond_to(:email) }

    it { should respond_to(:password) }
    it { should respond_to(:encrypted_password) }
  end



end