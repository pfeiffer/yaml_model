require 'yaml'

# YamlModel is a super-lightweight datastore for
# loading and accessing fixed, infrequently changing
# sets of data such as currencies or languages.
class YamlModel
  attr_reader :key
  
  class << self
    def yaml_file(path_or_file = nil)
      return @yaml_file unless path_or_file
      @yaml_file = path_or_file
    end
    
    # The complete hash of existing themes.
    def collection
      @collection ||= YAML.load_file(yaml_file).freeze
    end
    
    # The complete instantiated list of models
    def all
      @all ||= collection.inject([]){|result, (key, value)| result << self.new(key.to_s, value); result}.freeze
    end
    
    # Reset the collection to be reloaded again from YAML on the next call.
    def reset!
      @collection, @all, @instances = nil
    end
  
    # Find the mode
    def [](key)
      return nil unless collection.key?(key.to_s)
      (@instances ||= {})[key.to_s] ||= self.new(key, collection[key.to_s])
    end
    alias_method :find, :[]
    
    def attribute(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      attributes = args.last.is_a?(Hash) ? args.slice!(0, args.length - 1) : args
      
      attributes.each do |name|
        (@attributes ||= []) << name.to_s
        (@defaults ||= {})[name.to_s] = options.delete(:default)
      
        class_eval do
          attr_reader name
        end
      end
    end
    
    attr_reader :attributes
    attr_reader :defaults
  end
  
  # Instantiate the model with the provided key and attributes.
  def initialize(key, attrs = {})
    attrs = attrs.inject({}){|h,(k,v)| h[k.to_s] = v; h}
    @key = key.to_s
    self.class.attributes.each do |attribute|
      instance_variable_set("@#{attribute}", attrs[attribute.to_s] || self.class.defaults[attribute.to_s])
    end
  end
  
  def ==(other)
    other.is_a?(self.class) && self.key == other.key
  end
  
  def <=>(other)
    -(other <=> self.key)
  end
  
  def < (other); (self <=> other) < 0 end
  def <= (other); (self <=> other) <= 0 end
  def >= (other); (self <=> other) >= 0 end
  def > (other); (self <=> other) > 0 end
  
  def to_s
    key
  end
  alias_method :to_yaml, :to_s
  
  def to_sym
    key.to_sym
  end
end