# TokenChain

Generates a deterministic chain (or sequence) of tokens from a passphrase.

## Installation

Add this line to your application's Gemfile:

    gem 'token_chain'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install token_chain

## Usage

You can create a token chain from a passphrase:

```ruby
chain = TokenChain.from_passphrase 'the rain in spain'
chain.generate    #=> [first token]
chain.generate(2) #=> [second token, third token]
chain.anchor_code #=> anchor code for this chain, useful for restarting w/out passphrase
```

Provided you have a chain's anchor code, you can also "restart" a chain without the passphrase:

```ruby
chain = TokenChain.from_anchor [anchor code]
chain.generate #=> [first token]
```

You can even jumpstart the chain to generate from a previously generated token:

```ruby
chain = TokenChain.from_anchor [anchor code], [second code]
chain.generate #=> [third code]
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/token_chain/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
