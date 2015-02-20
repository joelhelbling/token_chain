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

    describe '#valid?' do
      When(:result) { receiver.valid? token }

      context 'totally bogus token' do
        Given { receiver.initialize_chain anchor }
        Given(:token) { 'ABC123' }
        Then { result == false }
      end

      context 'token from an uninitialized chain' do
        Given(:token) { generator.generate }
        Then { result == false }
      end

      context 'valid token' do
        Given { receiver.initialize_chain anchor }

        context 'first token' do
          Given(:token) { generator.generate }
          Then { result == true }
        end

        context 'from further down the chain' do
          Given(:token) { generator.generate(10).last }
          Then { result == true }
        end

        context 'from too far down the chain' do
          Given(:token) { generator.generate(11).last }
          Then { result == false }
        end
      end

    end #valid?

    describe '#validate!' do
      context 'totally bogus token' do
        Given(:token) { 'ABC!@#' }
        Then { expect{receiver.validate!(token)}.to raise_error(UnknownTokenError, "Invalid token") }
      end

      context 'valid token' do
        Given { receiver.initialize_chain anchor }

        context 'first token' do
          Given(:token) { generator.generate }
          When(:response) { receiver.validate!(token) }
          Then { expect(response[:result]).to eq('success') }
        end

        context 'valid token out of sequence' do
          Given(:token) { generator.generate(3).last }
          When(:response) { receiver.validate!(token) }
          describe 'response' do
            Then { expect(response[:result]).to eq('success') }
            Then { expect(response[:warning]).to eq('Token submitted out of sequence.') }
          end
          describe 'receivable tokens' do
            describe 'old/new token zero' do
              Then { ReceivableToken[token].sequence == -1 }
              Then { ReceivableToken[generator.generate].sequence == 0 }
            end
            describe 'new tokens created' do
              Given(:new_last_token) { generator.generate(10).last }
              Then { expect(ReceivableToken[new_last_token]).to be_available }
              Then { ReceivableToken[new_last_token].sequence == 9 }
            end
            describe 'skipped tokens' do
              Given(:skipped_token) { Generator.new(anchor).generate }
              Then { expect(ReceivableToken[skipped_token]).to_not be_available }
            end
          end
        end

      end

    end #validate!

  end
end
