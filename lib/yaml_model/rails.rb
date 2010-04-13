class YamlModel
  class Rails < ::YamlModel
    def self.yaml_file
      @yaml_file ||= ::Rails.root + "/config/#{name.to_s.underscore.pluralize}.yml"
    end
  end
end