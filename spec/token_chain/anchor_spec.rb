require 'spec_helper'
require 'token_chain/anchor'

module TokenChain
  describe Anchor do
    Given(:sha) { Digest::SHA256.new }
    Given(:passphrase) { 'the rain in spain' }
    Given(:second_seed) { sha.base64digest passphrase                }
    Given(:anchor_code) { sha.base64digest second_seed + passphrase  }
    When(:anchor) { described_class.from passphrase }

    context 'instantiation' do
      Then { anchor == anchor_code }
    end
  end
end
