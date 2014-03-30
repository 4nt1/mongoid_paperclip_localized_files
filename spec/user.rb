class User
  include Mongoid::Document
  include Mongoid::Paperclip::LocalizedFiles

  has_mongoid_localized_file :loc_file
  has_mongoid_attached_file  :not_loc_file

  embeds_many                 :children

end