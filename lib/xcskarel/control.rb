
module XCSKarel
  module Control
    def self.installed_xcodes
      unless (`mdutil -s /` =~ /disabled/).nil?
        # indexing is turned off
        return nil
      end

      status, output = self.execute('mdfind "kMDItemCFBundleIdentifier == \'com.apple.dt.Xcode\'" 2>/dev/null')
      raise "Failed to fetch Xcode paths: #{output}" if status != 0
      output.split("\n")
    end

    def self.start(xcode)
      raise "No Xcode path provided" unless xcode

      self.select(xcode)

      XCSKarel.log.info "Starting Xcode Server... This may take up to a minute.".yellow

      self.exec_sudo("sudo xcrun xcscontrol --initialize")
      self.exec_sudo("sudo xcrun xcscontrol --preflight")
      
      XCSKarel.log.info "Xcode Server started & running on localhost now!".green
    end

    def self.stop
      self.exec_sudo("sudo xcrun xcscontrol --shutdown")
    end

    def self.restart
      self.exec_sudo("sudo xcrun xcscontrol --restart")
    end

    def self.reset
      self.exec_sudo("sudo xcrun xcscontrol --reset")
    end

    def self.select(xcode)
      self.exec_sudo("sudo xcode-select -s #{xcode}")
    end

    private

    def self.exec_sudo(script)
      XCSKarel.log.warn "Running \'#{script}\', so we need root privileges."
      status, output = self.execute(script)
      raise "Failed to \'#{script}\':\n#{output}".red if status != 0
      XCSKarel.log.debug "Script \'#{script}\' output:\n#{output}"
      return status, output
    end

    def self.execute(script)
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
  end
end
