# The two properties the gem exists to satisfy.
#
# Scope: these cover dump/load fidelity, not the database reset. Under rspec the working
# directory is the gem root, which has no bin/rails, so the `system` call inside
# StaticDb::Load#reset_database! returns nil and the reset is inert — load_spec.rb pins
# that. What makes these meaningful is the fixture loader's own DELETE-then-INSERT.
RSpec.describe "round trips" do
  def dump_to(dir) = quietly { StaticDb::Dump.new(static_db_path: dir).perform }
  def load_from(dir) = quietly { StaticDb::Load.new(static_db_path: dir).perform }

  it "dump + load restores the database" do
    seed_corpus!
    before = db_snapshot

    dump_to(out_dir = static_db_dir)
    load_from(out_dir)

    expect(db_snapshot).to eq(before)
  end

  # Starts from committed YAML rather than a dump made moments earlier, so a change to
  # the emitted format fails here instead of quietly agreeing with itself.
  it "load + dump reproduces the YAML byte for byte" do
    load_from(golden_dir)

    dump_to(out_dir = static_db_dir)

    expect(dir_snapshot(out_dir)).to eq(dir_snapshot(golden_dir))
  end
end
