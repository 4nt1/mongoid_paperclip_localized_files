class Child
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in                :user
  has_mongoid_attached_file :id_pic, localize: true

end