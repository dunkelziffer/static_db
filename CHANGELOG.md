# Changelog

This project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

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
