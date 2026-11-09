# Configuration needs a booted app, but nothing here touches a database.
RSpec.describe "Configuration" do
  let(:unconfigured) { { "RAILS_ENV" => "development", "DUMMY_UNCONFIGURED" => "1" } }

  it "activates neither the load hook nor the dump hook by default" do
    hooks = DummyApp.in_booted_app(unconfigured) { { load: StaticDb.load?, dump: StaticDb.dump? } }

    expect(hooks).to eq(load: false, dump: false)
  end

  it "defaults to content/data for the data directory" do
    path = DummyApp.in_booted_app(unconfigured) { StaticDb.path.to_s }

    expect(path).to eq(DummyApp::ROOT.join("content", "data").to_s)
  end

  it "evaluates procs and other callables on every read" do
    reads = DummyApp.in_booted_app(unconfigured) do
      switch = [ false ]
      StaticDb.config.load = -> { switch.first }
      StaticDb.config.dump = Struct.new(:switch) { def call = !switch.first }.new(switch)
      StaticDb.config.static_db_path = -> { switch.first ? "/b" : "/a" }

      before = [ StaticDb.load?, StaticDb.dump?, StaticDb.path ]
      switch[0] = true
      [ before, [ StaticDb.load?, StaticDb.dump?, StaticDb.path ] ]
    end

    expect(reads).to eq([ [ false, true, "/a" ], [ true, false, "/b" ] ])
  end
end
