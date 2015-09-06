module XCSKarel
  module Shell
    def self.execute(script)
      XCSKarel.log.debug "Executing script: \"#{script}\""
      exit_status = nil
      result = []
      IO.popen(script, err: [:child, :out]) do |io|
        io.each do |line|
          result << line.strip
        end
        io.close
        exit_status = $?.exitstatus
      end
      [exit_status, result.join("\n")]
    end

    def self.exec_sudo(script)
      XCSKarel.log.warn "Running \'#{script}\', so we need root privileges."
      status, output = self.execute(script)
      raise "Failed to \'#{script}\':\n#{output}".red if status != 0
      XCSKarel.log.debug "Script \'#{script}\' output:\n#{output}"
      return status, output
    end
  end
end