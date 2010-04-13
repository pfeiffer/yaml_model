require File.dirname(__FILE__) + '/../spec_helper'

require 'active_support/inflector'
require 'yaml_model/rails'

module Rails; end unless defined? ::Rails

class ExampleOne < YamlModel::Rails
  
end

describe YamlModel::Rails do
  it 'should automagically set the yaml_model path' do
    ::Rails.should_receive(:root).and_return('/abc/def')
    ExampleOne.yaml_file.should == '/abc/def/config/example_ones.yml'
  end
end
