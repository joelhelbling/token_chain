require 'spec_helper'
require 'token_chain/anchor'
require 'token_chain/generator'
require 'token_chain/receivable_token'
require 'token_chain/receiver'

module TokenChain
  describe Receiver do
    Given { ReceivableToken.store = {} }
    Given(:anchor) { Anchor.from 'the rain in spain' }
    Given(:generator) { Generator.new anchor }
    Given(:store) { {} }
    Given(:receiver) { Receiver.new }

    describe '#initialize_chain' do
      When { receiver.initialize_chain anchor }
      Then { expect(ReceivableToken.keys.count).to eq(10) }
      Then { expect(ReceivableToken.map{|t| t.sequence}).to eq((0..9).to_a) }
      Then { expect(ReceivableToken[generator.generate(5).last]).to_not be_nil }
    end

    describe '#validate!' do
      # Return states:
      #   ✓ success (received token zero)
      #   ✓ success, warn token out of sequence
      #   ✓ fail: unknown token
      #   ✓ fail: previously submitted token
      context 'totally bogus token' do
        Given(:token) { 'ABC!@#' }
        Then { expect{receiver.validate!(token)}.to raise_error(UnknownTokenError, "Invalid token") }
      end

      context 'valid token' do
        Given { receiver.initialize_chain anchor }

        context 'token zero' do
          Given(:token) { generator.generate }
          When(:response) { receiver.validate!(token) }
          Then { expect(response[:result]).to eq('success') }
        end

        context 'out of sequence' do
          Given(:skipping_to) { 3 }
          When(:token) { generator.generate(skipping_to).last }
          When(:response) { receiver.validate!(token) }
          describe 'response' do
            context 'when skipping ahead' do
              Then { expect(response[:result]).to eq('success') }
              Then { expect(response[:warning]).to match(/out of sequence/) }
            end
            context 'when submitting a previously validated token' do
              Then { expect{receiver.validate!(token)}.to raise_error(/previously submitted/) }
            end
          end
          describe 'receivable tokens' do
            describe 'old/new token zero' do
              Then { ReceivableToken[token].sequence == -1 }
              Then { ReceivableToken[generator.generate].sequence == 0 }
            end
            describe 'new tokens created' do
              Given(:new_last_token) { Generator.new(anchor).generate(13).last }
              Given(:expected_sequences) { (-3..9).to_a }
              Then { expect(ReceivableToken[new_last_token]).to be_available }
              Then { ReceivableToken[new_last_token].sequence == 9 }
              Then { expect(ReceivableToken.map{|rt| rt.sequence}).to eq(expected_sequences) }
            end
            describe 'skipped tokens' do
              Given(:skipped_token) { Generator.new(anchor).generate }
              Then { expect(ReceivableToken[skipped_token]).to_not be_available }
            end
            describe 'more than 10 tokens consumed' do
              Given(:first_token) { Generator.new(anchor).generate }
              Given(:second_token) { Generator.new(anchor).generate(2).last }
              Given(:skipping_to) { 10 }
              When { receiver.validate! generator.generate }
              Then { expect(ReceivableToken[second_token]).to_not be_available }
              Then { expect(ReceivableToken[first_token]).to be_nil }
            end
          end
        end

        describe 'working repeatedly through a whole bunch of iterations' do
          Given { receiver.initialize_chain anchor }
          Given(:client_generator) { Generator.new anchor }
          Then do
            (0..50).map do
              skipping_to = 1 + rand(10)
              token = [client_generator.generate(skipping_to)].flatten.last
              response = receiver.validate!(token)
              response[:result] == 'success' && ReceivableToken.keys.count <= 20
            end.all? { |result| result == true }
          end

        end

      end

    end #validate!

  end
end
