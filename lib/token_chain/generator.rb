require 'digest/sha2'

module TokenChain
  class Generator
    attr_reader :codes, :anchor_code

    def initialize anchor_code, last_code=nil
      @anchor_code = anchor_code
      @last_code   = last_code
      @codes       = []
    end

    def generate quantity=1
      codes = make_new_codes quantity
      quantity > 1 ? codes : codes.last
    end

    def sha
      @sha ||= Digest::SHA2.new
    end

    private

    def make_new_codes number
      (1..number).inject([]) do |memo, _|
        part_one = memo.last || @codes.last || @last_code || @anchor_code
        part_two = @anchor_code

        memo << sha.base64digest("#{part_one}#{part_two}")
      end.tap do |new_codes|
        @codes.concat new_codes
      end
    end

  end
end
