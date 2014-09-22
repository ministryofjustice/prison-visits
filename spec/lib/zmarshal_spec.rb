require 'spec_helper'
require 'zmarshal'

describe ZMarshal do
  it "knows how to dump and restore objects" do
    object = Array.new(100, 15)
    ZMarshal.load(ZMarshal.dump(object)).should eq object
  end
end
