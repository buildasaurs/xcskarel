
module XCSKarel
  module Control
    def self.installed_xcodes
      unless (`mdutil -s /` =~ /disabled/).nil?
        # indexing is turned off
        return nil
      end

      status, output = XCSKarel::Shell.execute('mdfind "kMDItemCFBundleIdentifier == \'com.apple.dt.Xcode\'" 2>/dev/null')
      raise "Failed to fetch Xcode paths: #{output}" if status != 0
      output.split("\n")
    end

    def self.start(xcode)
      raise "No Xcode path provided" unless xcode

      self.select(xcode)

      XCSKarel.log.info "Starting Xcode Server... This may take up to a minute.".yellow

      XCSKarel::Shell.exec_sudo("sudo xcrun xcscontrol --initialize")
      XCSKarel::Shell.exec_sudo("sudo xcrun xcscontrol --preflight")
      
      XCSKarel.log.info "Xcode Server started & running on localhost now!".green
    end

    def self.stop
      XCSKarel::Shell.exec_sudo("sudo xcrun xcscontrol --shutdown")
    end

    def self.restart
      XCSKarel::Shell.exec_sudo("sudo xcrun xcscontrol --restart")
    end

    def self.reset
      XCSKarel::Shell.exec_sudo("sudo xcrun xcscontrol --reset")
    end

    def self.select(xcode)
      XCSKarel::Shell.exec_sudo("sudo xcode-select -s #{xcode}")
    end
  end
end
