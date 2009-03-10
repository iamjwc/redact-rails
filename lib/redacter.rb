module Redacter
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    @@redacters = {}

    def redact(*params)
      # A bit of dynamic programming to ensure Redacters aren't recreated
      # for each page request.
      @@redacters[self] ||= Redacter.new(params.flatten)

      # Adds a filter that will take the body of the response that is about
      # to be sent back to the client and redacts all of the appropriate
      # words from it.
      self.after_filter do |ctrlr|
        ctrlr.response.body = @@redacters[self].redact(ctrlr.response.body)
      end
    end
  end

  class Redacter
    def initialize(words)
      # Escapes all of the special regular expression characters from the
      # words that were passed in and joins them together to build a
      # regular expression that will match that word, regardless of case.
      words.map {|word| Regexp.escape(word) }
      @words_regex = /\b(#{words.join('|')})\b/i
    end

    def redact(input)
      input = input.dup
      output = ""

      # While what is left of the input matches a word that should be
      # redacted
      #   * Add all the text before it to the output
      #   * Add the correct amount of X's to represent the redacted word
      while match = input.match(@words_regex)
        output += match.pre_match
        output += 'X' * match[0].length
        input = match.post_match
      end

      # Add what is left of the input that did not match any redacted word.
      output += input
      output
    end
  end
end

