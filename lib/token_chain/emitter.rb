require 'token_chain/emittable_token'

module TokenChain
  class Emitter

    def initialize(anchor: nil, passphrase: nil)
      @emitter = weigh_anchor(anchor, passphrase)
    end

    def next_token!
      anchor         = @emitter.anchor
      previous_token = @emitter.last_consumed_token
      generator      = Generator.new(anchor, previous_token)

      generator.generate.tap do |token|
        @emitter.last_consumed_token = token
        @emitter.save
      end
    end

    private

    def weigh_anchor(anchor, passphrase)
      unless anchor || passphrase
        raise ArgumentError.new("You must provide an anchor or a passphrase.")
      end
      anchor = anchor || Anchor.from(passphrase)
      EmittableToken.find(anchor) || EmittableToken.create(anchor)
    end

  end # class Emitter
end
