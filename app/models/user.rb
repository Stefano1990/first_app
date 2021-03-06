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
  attr_accessor             :password
  
  attr_accessible           :name, 
                            :email, 
                            :password, 
                            :password_confirmation
  
  validates_presence_of     :name, 
                            :email,
                            :password
                            
  validates_uniqueness_of   :email,
                            :name
                            
  validates_length_of       :name, 
                            :email, 
                            :password, 
                            :within => 2..50
                            
  validates_format_of       :email, 
                            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
                            
  validates_confirmation_of :password
  
  before_save :encrypt_password
  
  has_many :microposts, :dependent => :destroy
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def feed
    Micropost.where("user_id = ?", id)
  end
  
  private
  
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
