class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  default_scope :order => 'microposts.created_at DESC'
  
  validates_presence_of :content, :user_id
  validates_length_of :content, :within => 4..140, :message => "Content too long or too short"
end
