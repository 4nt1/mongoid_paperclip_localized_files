# LocalizedFiles

LocalizedFiles allows you to store files in a model, related to a language.

LocalizedFiles enhance the possibility of the mongoid-paperclip gem. As you can localize a model string attributes, you can now localize files stored in your model.

## Installation

Add this line to your application's Gemfile:

    gem 'localized_files', git: 'https://github.com/4nt1/mongoid_paperclip_localized_files.git'

And then execute:

    $ bundle

## Usage

    class User
      include Mongoid::Document
      include Mongoid::Paperclip::LocalizedFiles

      has_mongoid_localized_file :truc

      # note that that including LocalizedFiles also include the usual Mongoid::Paperclip
      # so you can use :
      has_mongoid_attached_file  :bla
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
