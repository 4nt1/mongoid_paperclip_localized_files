# LocalizedFiles

LocalizedFiles allows you to store files in a model, related to a language.

LocalizedFiles enhance the possibility of the mongoid-paperclip gem. As you can localize a model string attributes, you can now localize files stored in your model.

## Installation

Add this line to your application's Gemfile:

    gem 'localized_files', git: 'https://github.com/4nt1/mongoid_paperclip_localized_files.git'

And then execute:

    $ bundle

## Usage

Add "include Mongoid::Paperclip::LocalizedFiles" to your model.
Define localized files with "has_mongoid_localized_file"
Note that this will also include Mongoid::Paperclip to your model, you can then use 'has_mongoid_attached_file' for other files

    class User
      include Mongoid::Document
      include Mongoid::Paperclip::LocalizedFiles

      has_mongoid_localized_file :truc
      has_mongoid_attached_file  :bla
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
