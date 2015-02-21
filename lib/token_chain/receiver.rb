require 'token_chain/anchor'
require 'token_chain/generator'
require 'token_chain/model_receivable_token'

module TokenChain
  class Receiver

    def initialize(datastore: {})
      ReceivableToken.store = datastore
    end

    def initialize_chain(anchor)
      @generator = Generator.new anchor
      @generator.generate(10).each_with_index do |token, i|
        ReceivableToken.create token, anchor: anchor, sequence: i
      end
    end

    def validate!(token)
      receivable = ReceivableToken.find(token)

      if receivable.nil?
        raise UnknownTokenError.new("Invalid token")
      elsif ! receivable.available?
        raise InvalidTokenError.new("Token was previously submitted")
      else # it's a valid, available token
        response = { result: 'success' }

        anchor = receivable.anchor
        incoming_token_seq = receivable.sequence

        if incoming_token_seq > 0
          response[:warning] = 'Token submitted out of sequence.'
        end

        # resequence and prune
        ReceivableToken.where(anchor: anchor).each do |rt|
          old_sequence = rt.sequence
          new_sequence = old_sequence - (incoming_token_seq + 1)
          rt.sequence = new_sequence
          if rt.sequence >= -10
            rt.status = :consumed if new_sequence < 0
            rt.save
          else
            rt.delete
          end
        end

        # replentish tokens
        first_new_token_seq = 9 - incoming_token_seq
        (first_new_token_seq..9).each do |sequence|
          ReceivableToken.create @generator.generate,
            anchor: anchor,
            sequence: sequence
        end

        return response
      end
    end

  end

  class UnknownTokenError < ArgumentError; end
  class InvalidTokenError < ArgumentError; end
end

