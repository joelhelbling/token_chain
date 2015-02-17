require 'spec_helper'
require 'token_chain/anchor'
require 'token_chain/generator'
require 'token_chain/model_receivable_token'
require 'token_chain/receiver'

module TokenChain
  describe Receiver do
    Given(:anchor) { Anchor.from 'the rain in spain' }
    Given(:generator) { Generator.new anchor }
    Given(:receiver) { Receiver.new }
    Given(:store) { {} }
    Given { ReceivableToken.store = store }

    describe '#initialize_chain' do
      When { receiver.initialize_chain anchor }
      Then { expect(store.keys.count).to eq(10) }
      Then { expect(ReceivableToken.map{|t| t.sequence}).to eq((0..9).to_a) }
      Then { expect(ReceivableToken[generator.generate(5).last]).to_not be_nil }
    end

    describe '#accept?' do
      When(:result) { receiver.accept? token }

      context 'valid token' do
        Given { receiver.initialize_chain anchor }
        Given(:token) { generator.generate }
        Then { result == true }
      end

      context 'totally bogus token' do
        Given(:token) { 'ABC123' }
        Then { result == false }
      end

      context 'token from an uninitialized chain' do
        Given(:token) { generator.generate }
        Then { result == false }
      end
    end

  end
end
