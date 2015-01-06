require 'token_chain/version'
require 'token_chain/anchor'
require 'token_chain/generator'

module TokenChain

  class << self

    def from_passphrase passphrase
      anchor_code = Anchor.from passphrase
      Generator.new anchor_code
    end

    def from_anchor anchor_code, last_code=nil
      Generator.new anchor_code, last_code
    end

  end

end
