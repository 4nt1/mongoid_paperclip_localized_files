# encoding: utf-8
# require "localized_files/version"
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

    @localized_file_fields = []
    field :localized_files,     type: Hash,   default: {}

    # define method on instantiation
    after_find do |that|
      that.localized_files.each do |field, locales|
        locales.each do |locale|
          define_mongoid_method(field, locale)
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

  Mongoid::Paperclip.module_eval do
    # we're in Mongoid::Paperclip module

    def define_mongoid_method(field, locale, options={})
      # we're in the instance
      # define the method on the class if not defined
      self.class_eval do
        # we're in the instance.class class
        has_mongoid_attached_file_original("#{field}_#{locale}".to_sym)
      end if !self.respond_to?("#{field}_#{locale}".to_sym)
    end

    Mongoid::Paperclip::ClassMethods.module_eval do

      # add accessor on the class
      attr_accessor :localized_file_fields
      # rename the :has_mongoid _attached_file method sur we can add features
      alias_method :has_mongoid_attached_file_original, :has_mongoid_attached_file

      def has_mongoid_attached_file(field, options={})

        # We just pass here once, when the instance.class class is loaded
        # Here comes the new option !
        if options.try(:[], :localize) == true
          localized_file_fields.push(field) if !localized_file_fields.include?(field)
          self.class_eval do
            # we are in the instance.class class

            # define getter
            define_method(field do |locale=I18n.locale|
              define_mongoid_method(field, locale, options)
              self.send("#{field}_#{locale}".to_sym)
            end

            # define setter
            define_method("#{field}=") do |file|
              locale = I18n.locale
              if file.is_a?(File) || file.nil?
                define_mongoid_method(field, locale, options)
                self.send("#{field}_#{locale}=".to_sym, file)
                presence = self.send("#{field}_#{locale}").present?
                update_localized_files_hash(field, locale, presence)
                file
              else
                raise new TypeError("wrong argument type #{file.class} (expected File)")
              end
            end

            # define setter helper
            define_method("#{field}_translations=") do |hashed_files|
              hashed_files.each do |locale, file|
                if (locale.is_a?(Symbol) || locale.is_a?(String)) && (file.is_a?(File) || file.nil?)
                  define_mongoid_method(field, locale, options)
                  self.send("#{field}_#{locale}=".to_sym, file)
                  presence = self.send("#{field}_#{locale}").present?
                  update_localized_files_hash(field, locale, presence)
                  file
                elsif file.is_a?(File) || file.nil?
                  raise new TypeError("wrong argument type #{locale.klass} (expected Symbol or String)")
                elsif locale.is_a?(Symbol) || locale.is_a?(String)
                  raise new TypeError("wrong argument type #{file.klass} (expected File)")
                end
                self.localized_files
              end
            end

            # define getter helper
            define_method("#{field}_translations") do
              self.localized_files["#{field}"]
            end

          end
        else
          options.delete(:localize)
          has_mongoid_attached_file_original(field, options)
        end
      end
    end
  end
end
