# frozen_string_literal: true

require 'stringio'

module StdioHelper
  def toward_stringio
    $stdout = StringIO.new
    yield $stdout if block_given?
  ensure
    $stdout = STDOUT
  end
end
