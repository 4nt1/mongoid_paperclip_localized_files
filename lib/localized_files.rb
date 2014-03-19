# encoding: utf-8
require "localized_files/version"
begin
  require "paperclip"
  require "mongoid_paperclip"
rescue LoadError
  puts "Mongoid::Paperclip::LocalizedFiles requires that you install the Paperclip and the Mongoid::Paperclip gem."
  exit
end
module Mongoid
  module Paperclip
    module LocalizedFiles
      extend ActiveSupport::Concern

      included do
        field :localized_files,     type: Hash,   default: {}

        after_find do |that|
          that.localized_files.each do |field, locales|
            locales.each do |locale|
              define_mongoid_method(field, locale)
            end
          end
        end

        def method_missing(meth, *args, &block)
          arr = "#{meth}".gsub('=', '').split('_').map(&:to_sym)
          if self.class.localized_file_fields.include?(arr[0])
            define_mongoid_method(arr[0], arr[1])
            self.send(meth, *args)
          else
            super
          end
        end


        def define_mongoid_method(field, locale, options={})
          self.class_eval do
            has_mongoid_attached_file("#{field}_#{locale}".to_sym, options)
            alias_method "#{field}_#{locale}_private=".to_sym, "#{field}_#{locale}=".to_sym
            alias_method "#{field}_#{locale}_private".to_sym, "#{field}_#{locale}".to_sym

            define_method("#{field}_#{locale}=") do |file|
              self.send("#{field}_#{locale}_private=".to_sym, file)
              presence = self.send("#{field}_#{locale}_private").present?
              update_localized_files_hash(field, locale, presence)
              file
            end

            define_method("#{field}_#{locale}") do
              self.send("#{field}_#{locale}_private".to_sym)
            end
          end
        end

        def update_localized_files_hash(field, locale, presence)
          locale = locale.to_sym
          self.localized_files["#{field}"] = [] if self.localized_files["#{field}"].blank?
          # adding a file
          if presence
            self.localized_files["#{field}"].push(locale) if !self.localized_files["#{field}"].include?(locale)
          # deleting a file
          elsif !presence
            self.localized_files["#{field}"].delete(locale) if self.localized_files["#{field}"].include?(locale)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        @@localized_file_fields = []

        def localized_file_fields
          @@localized_file_fields
        end

        def has_mongoid_localized_file(field, options = {})

          @@localized_file_fields.push(field) if !@@localized_file_fields.include?(field)

          define_method(field) do |locale=I18n.locale|
            define_mongoid_method(field, locale, options)
            self.send("#{field}_#{locale}".to_sym)
          end

          define_method("#{field}=") do |file|
            if file.is_a?(File) || file.nil?
              locale = I18n.locale
              define_mongoid_method(field, locale, options)
              self.send("#{field}_#{locale}=".to_sym, file)
            else
              raise new TypeError("wrong argument type File (expected File)")
            end
          end

          define_method("#{field}_translations=") do |hashed_files|
            hashed_files.each do |locale, file|
              if (locale.is_a?(Symbol) || locale.is_a?(String)) && (file.is_a?(File) || file.nil?)
                define_mongoid_method(field, locale, options)
                self.send("#{field}_#{locale}=".to_sym, file)
              else
                klass = (locale.is_a?(Symbol) || locale.is_a?(String)) ? 'Symbol or String' : 'File'
                raise new TypeError("wrong argument type File (expected #{klass})")
              end
              self.localized_files
            end
          end

          define_method("#{field}_translations") do
            self.localized_files["#{field}"]
          end

        end
      end
    end
  end
end
