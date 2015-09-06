module XCSKarel
  module Remote

    require 'net/ssh'

    # preferably set up SSH keys to be able to SSH into the host
    # see http://serverfault.com/a/241593 
    class Connection

      attr_reader :host
      attr_reader :user
      attr_reader :pass

      @ssh

      def initialize(host, user, pass)
        @host = host
        @user = user
        @pass = pass

        raise "Invalid host: \"#{host}\"".red if !host || host.empty?
        raise "Invalid user: \"#{user}\"".red if !user || user.empty?

        connect
      end

      def connect
        raise "Already connected".red if @ssh
        XCSKarel.log.info "Connecting to \"#{@host}\" as user \"#{@user}\" over SSH...".yellow
        @ssh = Net::SSH.start(host, user, :password => pass)
      end

      def disconnect
        @ssh.shutdown!
        @ssh = nil
      end

      def execute(script)
        raise "Not connected yet".red unless @ssh
        XCSKarel.log.debug "SSH: executing \"#{script}\"".green
        result = @ssh.exec!(script)
        result.strip! if result
        XCSKarel.log.debug "SSH: result\n \"#{result}\"".yellow
        return result
      end
    end
  end
end