# encoding: utf-8
require "localized_files/version"
begin
  require "paperclip"
  require "mongoid_paperclip"
rescue LoadError => e
  puts "LocalizedFiles requires that you install the Paperclip and the Mongoid::Paperclip gem : #{e.message}"
  exit
end
module LocalizedFiles
  extend ActiveSupport::Concern
  included do
    field :localized_files,     type: Hash,   default: {}
  end

  Mongoid::Paperclip.module_eval do
    # we're in Mongoid::Paperclip module

    def define_mongoid_method(field, locale, options={})
      # we're in the instance
      # define the method on the class if not defined
      self.class.has_mongoid_attached_file_original("#{field}_#{locale}".to_sym) if !respond_to?("#{field}_#{locale}".to_sym)
    end

    Mongoid::Paperclip::ClassMethods.module_eval do
      # rename the :has_mongoid _attached_file method sur we can add features
      alias_method :has_mongoid_attached_file_original, :has_mongoid_attached_file

      def define_instance_methods(field, options)

        define_method "update_localized_files_hash" do |field, locale, presence|
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

        # define getter
        define_method(field) do |locale=I18n.locale|
          define_mongoid_method(field, locale, options)
          self.send("#{field}_#{locale}".to_sym)
        end

        # define setter
        define_method("#{field}=") do |file|
          locale = I18n.locale
          define_mongoid_method(field, locale, options)
          self.send("#{field}_#{locale}=".to_sym, file)
          presence = self.send("#{field}_#{locale}").present?
          update_localized_files_hash(field, locale, presence)
          file
        end

        # define setter helper
        define_method("#{field}_translations=") do |hashed_files|
          hashed_files.each do |locale, file|
            define_mongoid_method(field, locale, options)
            self.send("#{field}_#{locale}=".to_sym, file)
            presence = self.send("#{field}_#{locale}").present?
            update_localized_files_hash(field, locale, presence)
            self.localized_files
          end
        end

        # define getter helper
        define_method("#{field}_translations") do
          self.localized_files["#{field}"]
        end
      end

      def has_mongoid_attached_file(field, options={})
        # We just pass here once, when the instance.class class is loaded
        # Here comes the new option !
        if options.try(:[], :localize) == true
          # localized_file_fields.push(field) if !localized_file_fields.include?(field)
          self.class_eval do
            define_instance_methods(field, options)
          end
        else
          options.delete(:localize)
          has_mongoid_attached_file_original(field, options)
        end
      end
    end
  end
end