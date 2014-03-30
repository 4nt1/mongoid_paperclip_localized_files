# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localized_files/version'

Gem::Specification.new do |spec|
  spec.name          = "localized_files"
  spec.version       = LocalizedFiles::VERSION
  spec.authors       = ["4nt1"]
  spec.email         = ["antoinemary@hotmail.fr"]
  spec.summary       = %q{LocalizedFiles allows you to store files in a model, related to a language.}
  spec.description   = %q{LocalizedFiles enhance the possibility of the mongoid-paperclip gem. As you can localize a model string attributes, you can now localize files stored in your model.}
  spec.homepage      = "https://github.com/4nt1/mongoid_paperclip_localized_files"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake"
  spec.add_dependency "paperclip", "3.5.2"
  spec.add_dependency "mongoid-paperclip"
  spec.add_development_dependency "rspec"

end
