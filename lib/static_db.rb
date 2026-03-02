# frozen_string_literal: true

require "static_db/version"
require "static_db/dump"
require "static_db/load"
require "static_db/engine" if defined?(Rails::Railtie)
