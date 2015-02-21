require 'squares'

module TokenChain
  class ReceivableToken < Squares::Base
    property :anchor
    property :sequence, default: 0

    alias_method :token, :id

    def available?
      sequence >= 0
    end
  end
end
