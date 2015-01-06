require 'spec_helper'
require 'token_chain/generator'

module TokenChain
  describe Generator do
    Given(:sha)         { Digest::SHA256.new                         }
    Given(:passphrase)  { 'the rain in spain'                        }
    Given(:second_seed) { sha.base64digest passphrase                }
    Given(:anchor_code) { sha.base64digest second_seed + passphrase  }
    Given(:first_code)  { sha.base64digest anchor_code + anchor_code }
    Given(:second_code) { sha.base64digest first_code  + anchor_code }
    Given(:third_code)  { sha.base64digest second_code + anchor_code }

    context 'anchor with no last code' do
      Given(:chain) { described_class.new anchor_code }

      describe 'generates a token' do
        When(:result) { chain.generate }
        Then { result == first_code }
      end

      describe 'generates multiple tokens' do
        When(:result) { chain.generate(3) }
        Then { result == [ first_code, second_code, third_code ] }
      end

      describe 'return just the generated tokens' do
        When { chain.generate }
        When(:result) { chain.generate(2) }
        Then { result == [ second_code, third_code ] }
      end
    end

    context 'anchor with a last code' do
      Given(:last_code)   { third_code                                 }
      Given(:fourth_code) { sha.base64digest third_code  + anchor_code }
      Given(:fifth_code)  { sha.base64digest fourth_code + anchor_code }
      Given(:chain)       { described_class.new anchor_code, last_code }

      describe 'generates a token' do
        When(:result) { chain.generate }
        Then { result == fourth_code }
      end

      describe 'generates multiple tokens' do
        When(:result) { chain.generate(2) }
        Then { result == [ fourth_code, fifth_code ] }
      end
    end

  end
end
