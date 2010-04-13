require 'yaml_model'

class YamlModel
  class Rails < ::YamlModel
    def self.yaml_file
      @yaml_file ||= ::Rails.root.to_s + "/config/#{name.to_s.underscore.pluralize}.yml"
      super
    end
  end
end