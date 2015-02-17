require 'token_chain/anchor'
require 'token_chain/generator'
require 'token_chain/model_receivable_token'

module TokenChain
  class Receiver

    # perhaps this be called #authenticate! since it has a side-effect
    def accept?(token)
      ReceivableToken.keys.include? token
    end

    def initialize_chain(anchor)
      generator = Generator.new anchor
      generator.generate(10).each_with_index do |token, i|
        ReceivableToken.create token, anchor: anchor, sequence: i
      end
    end

  end
end

