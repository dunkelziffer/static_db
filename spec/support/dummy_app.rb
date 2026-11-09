require "open3"
require "pathname"

# Runs the dummy app in child processes, never in the spec process.
module DummyApp
  ROOT = Pathname(__dir__).join("..", "dummy").expand_path

  Result = Data.define(:command, :status, :stdout, :stderr) do
    def success? = status.success?

    def to_s
      "`#{command.join(" ")}` exited with #{status.exitstatus}\n" \
        "--- stdout\n#{stdout}\n--- stderr\n#{stderr}"
    end
  end

  ChildError = Class.new(StandardError)

  class << self
    # Runs a command from the dummy app's root, as a user would from a terminal. The
    # process group is killed on timeout, which includes the `bin/rails` that
    # StaticDb::Load spawns.
    def run(*command, env:, input: "", timeout: 120)
      Open3.popen3(env, *command, chdir: ROOT.to_s, pgroup: true) do |stdin, stdout, stderr, process|
        output = [ stdout, stderr ].map { |io| Thread.new { io.read } }
        write_input(stdin, input)

        unless process.join(timeout)
          Process.kill("KILL", -process.pid)
          raise "timed out after #{timeout}s: #{command.join(" ")}"
        end

        Result.new(command:, status: process.value, stdout: output[0].value, stderr: output[1].value)
      end
    end

    # Boots the dummy app in a forked child and returns what the block returns. Used to
    # arrange and inspect databases, never to run static_db.
    def in_booted_app(env, &block)
      reader, writer = IO.pipe
      pid = fork do
        reader.close
        writer.write(Marshal.dump(boot_and_call(env, &block)))
        writer.close
        exit!(true) # Skips the at_exit handlers inherited from rspec.
      end
      writer.close
      outcome = reader.read
      reader.close
      Process.wait(pid)
      raise ChildError, "booted app died without reporting back (#{$?})" if outcome.empty?

      status, value, backtrace = Marshal.load(outcome)
      raise ChildError, value, backtrace if status == :error

      value
    end

    private

    def write_input(stdin, input)
      stdin.write(input)
    rescue Errno::EPIPE
      # The process exited before reading its input, e.g. because the boot failed.
    ensure
      stdin.close
    end

    def boot_and_call(env)
      env.each { |name, value| ENV[name] = value }
      Dir.chdir(ROOT)
      require ROOT.join("config", "environment").to_s

      [ :ok, yield ]
    rescue Exception => e # rubocop:disable Lint/RescueException
      # Only strings cross the pipe: the parent has no Rails to unmarshal its exceptions.
      [ :error, "#{e.class}: #{e.message}", e.backtrace ]
    end
  end
end
