# == Schema Information
# Schema version: 20100806152438
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  attr_accessible :name, :email
  
  validates_presence_of  :name, :email, :on => :create
  validates_uniqueness_of :name, :email, :on => :create
  validates_length_of :name, :within => 4..50, :on => :create
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
end
