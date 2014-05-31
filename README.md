# LocalizedFiles

LocalizedFiles allows you to store files in a model, related to a language.

LocalizedFiles enhance the possibility of the mongoid-paperclip gem. As you can localize a model string attributes, you can now localize files stored in your model.

## Installation

Add this line to your application's Gemfile:

    gem 'localized_files', git: 'https://github.com/4nt1/mongoid_paperclip_localized_files.git'

And then execute:

    $ bundle

## Usage

```rb
    class User
      include Mongoid::Document
      include LocalizedFiles

      has_mongoid_attached_file :some_file,     localize: true

      # note that that including LocalizedFiles also include the usual Mongoid::Paperclip
      # so you can use :
      has_mongoid_attached_file  :some_other_file
    end

    u = User.new
    f = File.open('path_to_file')

    I18n.locale
    => :en

    # simple affectation links the file instance to the current locale
    u.some_file = f
    => #<File:path_to_file>

    # helper method summarizes files /languages links
    u.localized_files
    => {"some_file"=>[:en]}

    # change locale to set it to another language
    I18n.locale = :fr
    => :fr
    u.some_file = f
    => #<File:path_to_file>
    u.localized_files
    => {"some_file"=>[:en, :fr]}

    # or use direct setter
    u.some_file_es = f
    => #<File:path_to_file>
    u.localized_files
    => {"some_file"=>[:en, :fr, :es]}

    # set one or multiple file using a hash, you're not limited to locales symbol
    u.some_file_translations= {de: f, i_do_not_need: f}
    => {:de=>#<File:path_to_file>, :i_do_not_need=>#<File:path_to_file>}

    # get specific file without changing locale
    u.some_file(:en)
    => #<Paperclip::Attachment:0x007fed5fbf75f8 @name=:some_file_en ... >

    # or use direct getter
    u.some_file_i_do_not_need
    => #<Paperclip::Attachment:0x007fed5bcea2c0 @name=:some_file_my_super ...>
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
