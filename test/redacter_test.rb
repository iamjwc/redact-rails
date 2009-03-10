require 'test/unit'
require 'redacter'

class RedacterTest < Test::Unit::TestCase
  def setup
    @redacter = Redacter::Redacter.new(["I", "like to", "redact", "stuff"])
  end

  def test_simple_redact
    test_text = <<-TEXT
This is text that should be redacted. Nothing yet should be redacted.
I do like to do stuff. Redacting is cool. Its fun to say as well...
I like it. Redact redact redact.
    TEXT
    redacted_test_text = <<-TEXT
This is text that should be redacted. Nothing yet should be redacted.
X do XXXXXXX do XXXXX. Redacting is cool. Its fun to say as well...
X like it. XXXXXX XXXXXX XXXXXX.
    TEXT

    assert_equal redacted_test_text, @redacter.redact(test_text)
  end
end
