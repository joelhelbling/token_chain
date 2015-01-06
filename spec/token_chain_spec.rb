require 'spec_helper'

describe TokenChain do
  it 'should have a version number' do
    expect(TokenChain::VERSION).to_not be_nil
  end
end
