require 'spec_helper'
require 'token_chain/anchor'
require 'token_chain/emittable_token'
require 'token_chain/emitter'

module TokenChain
  describe Emitter do
    Given { EmittableToken.store = {} }
    Given(:passphrase) { 'the rain in spain' }
    Given(:anchor) { Anchor.from passphrase }
    Given(:generator) { Generator.new anchor }

    describe '#initialize' do
      describe 'with an anchor' do
        When { Emitter.new anchor: anchor }
        Then { expect( EmittableToken[anchor] ).to_not be_nil }
        Then { expect( EmittableToken[anchor].last_consumed_token ).to be_nil }
      end

      describe 'with a passphrase' do
        When { Emitter.new passphrase: passphrase }
        Then { expect( EmittableToken[anchor] ).to_not be_nil }
        Then { expect( EmittableToken.find(anchor).last_consumed_token ).to be_nil }
      end

      describe 'with neither anchor nor passphrase' do
        Then { expect{ Emitter.new }.to raise_error(/provide an anchor or a passphrase/) }
      end
    end #initialize

    describe '#next_token!' do
      Given(:emitter) { Emitter.new anchor: anchor }

      context 'first consumed token' do
        Given(:expected_token) { generator.generate }

        When(:token) { emitter.next_token! }

        Then { expect(token).to eq(expected_token) }
        Then { expect(EmittableToken[anchor].last_consumed_token).to eq(expected_token) }
      end

      context 'second consumed token' do
        Given(:expected_token) { generator.generate(2).last }
        Given { emitter.next_token! }

        When(:token) { emitter.next_token! }

        Then { expect(token).to eq(expected_token) }
        Then { expect(EmittableToken[anchor].last_consumed_token).to eq(expected_token) }
      end
    end

  end
end
