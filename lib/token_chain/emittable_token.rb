require 'squares'

module TokenChain
  class EmittableToken < Squares::Base
    property :last_consumed_token

    alias_method :anchor, :id
  end
end
