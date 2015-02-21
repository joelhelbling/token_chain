require 'squares'

module TokenChain
  class ReceivableToken < Squares::Base
    property :anchor
    property :sequence, default: 0
    property :status, default: :available # also, :consumed

    alias_method :token, :id

    def available?
      status == :available
    end
  end
end
