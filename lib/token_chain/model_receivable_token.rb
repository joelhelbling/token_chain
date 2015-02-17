require 'squares'

module TokenChain
  class ReceivableToken < Squares::Base
    property :anchor
    property :sequence, default: 0
    property :used_at

    alias_method :token, :id

    def spent?
      ! used_at.nil?
    end
  end
end
