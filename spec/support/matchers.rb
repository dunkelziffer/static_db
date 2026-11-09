RSpec::Matchers.define :exit_successfully do
  match(&:success?)
  failure_message { |result| "expected success, but #{result}" }
end

# Compares two Snapshot.files results and reports per file, with a line diff.
RSpec::Matchers.define :match_files do |expected|
  match { |actual| actual == expected }

  failure_message do |actual|
    report = []
    (expected.keys - actual.keys).each { |name| report << "missing #{name}" }
    (actual.keys - expected.keys).each { |name| report << "unexpected #{name}" }
    (actual.keys & expected.keys).reject { |name| actual[name] == expected[name] }.each do |name|
      report << "#{name} differs:#{RSpec::Expectations.differ.diff(text(actual[name]), text(expected[name]))}"
    end
    report.join("\n")
  end

  def text(bytes) = bytes.dup.force_encoding(Encoding::UTF_8)
end
