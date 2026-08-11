module Quiet
  # Dump and Load narrate to stdout, and Load shells out to `bin/rails`, which narrates
  # too. Swapping the Ruby-level $stdout object would not touch the subprocess, so
  # redirect the file descriptor itself.
  def quietly
    saved = $stdout.dup
    $stdout.reopen(File::NULL)
    yield
  ensure
    $stdout.reopen(saved)
    saved.close
  end
end

RSpec.configure do |config|
  config.include Quiet

  # Dump#perform exits when this is set, and Load#perform sets it on failure. A global
  # surviving into the next example would be invisible and order-dependent.
  config.before { $skip_static_db_dump = nil }
end
