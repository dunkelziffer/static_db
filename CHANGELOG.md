# Changelog

This project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

### Breaking

-

### Non-breaking

-

## [0.2.0] - 2026-05-08

### Breaking

- Config option `fixture_path` was renamed to `static_db_path`.
- The Rails boot sequence hooks are no longer active automatically. You need to opt-in via the config options `load` and `dump`.
- The Rails boot sequence hooks no longer run for any `* build` command. They only run for `parklife build`.

### Non-breaking

- All config options now support Procs or any other object responding to `.call()`.
  - The default Proc for config option `static_db_path` now gets evaluated correctly.
- Internal code cleanup

## [0.1.1] - 2026-05-03

### Breaking

-

### Non-breaking

- Remove unused dependency on `ostruct`

## [0.1.0] - 2026-05-03

### Breaking

- Drop database at a different point in time now. It's possible, but unlikely that this breaks anything for you.
  - Previously: `db:drop` happend after dumping out data on shutdown.
    - If dumping data failed, your `.sqlite3` files would remain and the next boot would fail.
    - If everything succeeded, it worked OK, but keeping the `.sqlite3` files around might still be beneficial.
  - Now: `db:drop` happens before loading data on boot.
    - After a failed shutdown (e.g. due to validation errors), you don't need to manually delete the files anymore.
      Restarting your Rails servers discards all data changes.
    - After an interrupted shutdown (e.g. `bin/dev` / `foreman` killing your Rails process too early) you can
      now retry dumping data via `bin/rails static:dump`.

### Non-breaking

- Internal code cleanup
