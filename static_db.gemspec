require_relative "lib/static_db/version"

Gem::Specification.new do |s|
  s.name = "static_db"
  s.version = StaticDb::VERSION
  s.authors = ["Klaus Weidinger"]
  s.email = ["weidkl@gmx.de"]
  s.license = "MIT"

  s.summary = "Dump DB contents to YAML and load them back again. Aimed at SQLite. Committable to git."
  s.description = s.summary
  s.homepage = "https://github.com/dunkelziffer/static_db"

  s.metadata = {
    "source_code_uri" => s.homepage,
    "homepage_uri" => s.homepage,
    "changelog_uri" => "#{s.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{s.homepage}/issues",
    "documentation_uri" => "#{s.homepage}/blob/main/README.md",
    "rubygems_mfa_required" => "true"
  }

  # === CONTENTS ===

  gemspec = File.basename(__FILE__)
  s.files = `git ls-files`
    .split("\n")
    .reject { |f| File.symlink?(f) }
    .reject { |f| f == gemspec }
    .reject { |f| f.start_with?(*%w[.github/ bin/ spec/ .gem_release.yml .gitignore .rspec .rubocop.yml .ruby-version Gemfile Gemfile.lock RELEASING.md]) }
  s.require_paths = [ "lib" ]

  s.bindir = "exe"
  s.executables = []

  # === DEPENDENCIES ===

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "rails", ">= 7.2"
  s.add_dependency "ostruct", ">= 0.6"
end
