class User
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file  :loc_file, localize: true
  has_mongoid_attached_file  :not_loc_file

  embeds_many                 :children

end