require 'token_chain/anchor'
require 'token_chain/generator'
require 'token_chain/model_receivable_token'

module TokenChain
  class Receiver

    def initialize_chain(anchor)
      @generator = Generator.new anchor
      @generator.generate(10).each_with_index do |token, i|
        ReceivableToken.create token, anchor: anchor, sequence: i
      end
    end

    def valid?(token)
      if rt = ReceivableToken.find(token)
        rt.available?
      else
        false
      end
    end

    def validate!(token)
      if valid?(token)
        response = { result: 'success' }
        receivable = ReceivableToken.find(token)

        anchor = receivable.anchor
        incoming_token_seq = receivable.sequence

        if incoming_token_seq > 0
          response[:warning] = 'Token submitted out of sequence.'
        end

        ReceivableToken.where(anchor: anchor).each do |rt|
          old_sequence = rt.sequence
          new_sequence = old_sequence - (incoming_token_seq + 1)
          rt.sequence = new_sequence
          if new_sequence < 0
            rt.status = :consumed
          end
          rt.save
        end

        # replentish tokens
        first_new_token_seq = 9 - incoming_token_seq
        (first_new_token_seq..9).each do |sequence|
          ReceivableToken.create @generator.generate,
            anchor: anchor,
            sequence: sequence
        end

        # purge old consumed tokens (keep 10)

        return response
      else
        raise UnknownTokenError.new("Invalid token") unless valid?(token)
      end
    end

  end

  class UnknownTokenError < ArgumentError; end
end

