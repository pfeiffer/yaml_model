require File.dirname(__FILE__) + '/spec_helper'

class ExampleYamlModel < YamlModel
  attribute :name, :players
  attribute :scheme, :default => 'skeeball'
end

describe YamlModel do
  before do 
    @fixture = {
      "ABC" => {
        "name" => "Always Be Coding"
      },

      "DEF" => {
        "name" => "Defense Electric Fort",
        "scheme" => "snowball"
      },
      
      "GHI" => {
        "name" => "Gordon's Heaving International",
        "scheme" => "foosball",
        "players" => 10
      }
    }
    
    YAML.stub!(:load_file).and_return(@fixture)
  end
  
  describe '.yaml_file' do
    it 'should set and retrieve a class instance variable' do
      ExampleYamlModel.yaml_file '/awesome.yml'
      ExampleYamlModel.yaml_file.should == '/awesome.yml'
    end
  end
  
  describe '.collection' do
    it 'should be the YAML loading of config/tableized_model_name.yml with symbolized keys' do
      YAML.should_receive(:load_file).and_return(@theme_fixture)
      ExampleYamlModel.collection
    end
    
    it 'should be a hash' do
      ExampleYamlModel.collection.should be_kind_of(Hash)
    end
    
    it 'should memoize' do
      YAML.should_receive(:load_file).once.and_return(@theme_fixture)
      3.times{ExampleYamlModel.collection}
    end
  end
  
  describe '.all' do
    it 'should instantiate an array of the example objects' do
      ExampleYamlModel.all.should be_include(ExampleYamlModel[:GHI])
    end
    
    it 'should be the same length as the collection' do
      ExampleYamlModel.all.size.should == ExampleYamlModel.collection.size
    end
    
    it 'should initialize with proper attributes' do
      t = ExampleYamlModel.all.select{|e| e.key == "ABC"}.first
      t.name.should == "Always Be Coding"
    end
    
    it 'should memoize' do
      collection = ExampleYamlModel.collection
      ExampleYamlModel.should_receive(:collection).once.and_return(collection)
      3.times{ExampleYamlModel.all}
    end
  end
  
  describe '.reset!' do
    it 'should clear the collection' do
      ExampleYamlModel.instance_variable_set(:@collection, "abc")
      ExampleYamlModel.reset!
      ExampleYamlModel.instance_variable_get(:@collection).should be_nil
    end
    
    it 'should clear the .all cache' do
      ExampleYamlModel.instance_variable_set(:@all, "aoisdasd")
      ExampleYamlModel.reset!
      ExampleYamlModel.instance_variable_get(:@all).should be_nil
    end
  end
  
  describe "[]" do
    it 'should instantiate the theme specified by the key' do
      ExampleYamlModel[:ABC].name.should == 'Always Be Coding'
    end
    
    it 'should be nil if a non-existent theme is passed' do
      ExampleYamlModel[:nonexistent].should be_nil
    end
    
    it 'should be indifferent to string/symbol' do
      ExampleYamlModel["ABC"].should == ExampleYamlModel[:ABC]
    end
    
    it 'should be memoized' do
      ExampleYamlModel.should_receive(:new).once.with("ABC", "name" => 'Always Be Coding').and_return('wakka')
      3.times{ExampleYamlModel["ABC"]}
    end
  end
  
  describe ' sorting' do
    it ' <=> should compare using the key' do
      (ExampleYamlModel.new('abc') <=> ExampleYamlModel.new('bed')).should == -1
      (ExampleYamlModel.new('abc') <=> ExampleYamlModel.new('abc')).should == 0
      (ExampleYamlModel.new('bed') <=> ExampleYamlModel.new('abc')).should == 1
    end
    
    it 'should use < properly' do 
      (ExampleYamlModel.new('abc') < ExampleYamlModel.new('bed')).should == true
      (ExampleYamlModel.new('bed') < ExampleYamlModel.new('abc')).should == false
      (ExampleYamlModel.new('bed') < ExampleYamlModel.new('bed')).should == false
    end
    
    it 'should use > properly' do 
      (ExampleYamlModel.new('abc') > ExampleYamlModel.new('bed')).should == false
      (ExampleYamlModel.new('bed') > ExampleYamlModel.new('abc')).should == true
      (ExampleYamlModel.new('bed') > ExampleYamlModel.new('bed')).should == false      
    end
    
    it 'should use >= properly' do
      (ExampleYamlModel.new('abc') >= ExampleYamlModel.new('bed')).should == false
      (ExampleYamlModel.new('bed') >= ExampleYamlModel.new('abc')).should == true
      (ExampleYamlModel.new('bed') <= ExampleYamlModel.new('bed')).should == true
    end
    
    it 'should use <= properly' do 
      (ExampleYamlModel.new('abc') <= ExampleYamlModel.new('bed')).should == true
      (ExampleYamlModel.new('bed') <= ExampleYamlModel.new('abc')).should == false
      (ExampleYamlModel.new('bed') <= ExampleYamlModel.new('bed')).should == true
    end
  end
  
  describe '.attribute' do
    it 'should add the specified attribute to the attributes list' do
      ExampleYamlModel.attributes.should be_include('name')
    end
    
    it 'should be able to specify a default' do
      ExampleYamlModel.new(:test).scheme.should == 'skeeball'
    end
    
    it 'should be able to add multiple attributes as an array' do
      ExampleYamlModel.attributes.should be_include('players')
    end
  end
  
  describe ".find" do
    it 'should be the same as ExampleYamlModel[]' do
      ExampleYamlModel.find(:ABC).should == ExampleYamlModel[:ABC]
    end
  end
  
  describe '#new' do
    it 'should allow for the attributes to be set' do
      ExampleYamlModel.new(:test, :name => 'Awesome ExampleYamlModel').name.should == 'Awesome ExampleYamlModel'
      ExampleYamlModel.new(:test, :scheme => 'bocciball').scheme.should == 'bocciball'
      ExampleYamlModel.new(:test).key.should == "test"
    end
  end
  
  describe '#to_s' do
    it 'should be the string representation of the key' do
      ExampleYamlModel[:ABC].to_s.should == ExampleYamlModel[:ABC].key.to_s
    end
  end
  
  after do
    ExampleYamlModel.reset!
  end
end