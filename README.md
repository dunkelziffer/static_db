[![Gem Version](https://badge.fury.io/rb/static_db.svg)](https://rubygems.org/gems/static_db)
[![Build](https://github.com/dunkelziffer/static_db/workflows/Build/badge.svg)](https://github.com/dunkelziffer/static_db/actions)

# static_db

Dump DB contents to YAML and load them back again.

This gem provides:
- Methods: `StaticDb::Load.new.perform` and `StaticDb::Dump.new.perform`
- Rake tasks: `static:load` and `static:dump` (available automatically in Rails projects)
- Hooks for the Rails boot sequence: off by default, but the main purpose of this gem. See configuration below.

> ℹ️ The original main use case for this gem are static site generators built on top of Ruby on Rails.
> However, the DB (de)serialization functionality is useful enough on its own, so the decision was made
> to disable any behavior by default, which could result in data loss for regular Rails applications.
> You can opt into the Rails boot sequence hooks via config.

## Installation

Add it to your Rails project:

```ruby
# Gemfile
gem "static_db"
```

This example initializer shows a flexible way how to opt into the Rails boot sequency hooks:

```ruby
# config/initializer/static_db.rb
StaticDb.configure do |config|
  config.static_db_path = Rails.root.join("content", "data")

  # Selectively activate loading and dumping. Active by default. Set to any other value to disable.
  config.load = ENV["STATIC_DB"].in? [ "load", nil, "on", "true", "1" ]
  config.dump = ENV["STATIC_DB"].in? [ "dump", nil, "on", "true", "1" ]
end
```

Now, starting your Rails server will reset your DB and load YAML fixtures from `content/data`. Exiting the server with `Ctrl+C` will dump out your DB as YAML fixtures to that directory.

All config options support procs.

## Hook activation

The boot sequence hooks are active in the following scenarios:
- When you run any server command: `bin/rails s`
- When you run any console command: `bin/rails c`
- When you run `parklife build`

> ℹ️ If you already have your dev server running and want to start an additional console, avoid conflicts by using `STATIC_DB=0 bin/rails c` (with the example initializer from above).

The boot sequence hooks are inactive in all other cases, e.g.:
- When you run tests: `bin/rails t` or `bin/rails test:system`
- When you run migrations: `bin/rails db:migrate`
- When you run any other rake tasks

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/dunkelziffer/static_db](https://github.com/dunkelziffer/static_db).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
