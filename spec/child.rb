class Child
  include Mongoid::Document
  include Mongoid::Paperclip::LocalizedFiles

  embedded_in                :user
  has_mongoid_localized_file :id_pic

end