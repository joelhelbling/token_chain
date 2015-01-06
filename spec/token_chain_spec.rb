require 'spec_helper'

describe TokenChain do
  it 'should have a version number' do
    expect(TokenChain::VERSION).to_not be_nil
  end

  describe 'two ways to make a chain' do
    Given(:chain1) { TokenChain.from_passphrase 'the rain in spain' }
    When(:chain2)  { TokenChain.from_anchor chain1.anchor_code }
    Then { chain1.generate == chain2.generate }
  end
end
