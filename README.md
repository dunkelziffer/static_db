[![Gem Version](https://badge.fury.io/rb/static_db.svg)](https://rubygems.org/gems/static_db)
[![Build](https://github.com/dunkelziffer/static_db/workflows/Build/badge.svg)](https://github.com/dunkelziffer/static_db/actions)

# static_db

Dump DB contents to YAML and load them back again. Aimed at SQLite. Committable to git.

## Installation

WARNING: This gem modifies the Rails startup sequence. Don't use this gem unless you want to build a static site generator. This gem also creates and drops the DB for you.

Add it to your Rails project:

```ruby
# Gemfile
gem "static_db"

# config/initializer/static_db.rb
StaticDb.configure do |config|
  # `content/data` is the default. You only need this initializer,
  # if you want a custom path.
  config.fixture_path = Rails.root.join("content", "data")
end
```

## Usage

Only use on Rails projects with SQLite. Have a valid `db/schema.rb`. For additional dramatic effect, do a `rails db:drop`.

Start your app with `bin/dev`. You will notice that a DB gets created for you. It will be empty.

Create some records. Then, stop your server with Ctrl+C.

The DB contents will have been dumped to `content/data`. Your SQLite DB will be gone.

Restart your server with `bin/dev`. Your SQLite DB will be back and populated with all previously stored data, recreated from `content/data`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/dunkelziffer/static_db](https://github.com/dunkelziffer/static_db).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
