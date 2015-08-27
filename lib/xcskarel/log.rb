require 'logger'
require 'colored'

module XCSKarel

  @@NO_LOG = false

  def self.set_no_log(no_log)
    @@NO_LOG = no_log
  end

  def self.log

    @@log ||= Logger.new($stdout)
    @@log.level = @@NO_LOG ? Logger::Severity::INFO : Logger::Severity::DEBUG
    @@log.formatter = proc do |severity, datetime, progname, msg|

      string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: "
      second = "#{msg}\n"

      if severity == "DEBUG"
        string = string.magenta
      elsif severity == "INFO"
        string = string.white
      elsif severity == "WARN"
        string = string.yellow
      elsif severity == "ERROR"
        string = string.red
      elsif severity == "FATAL"
        string = string.red.bold
      end

      [string, second].join("")
    end
    @@log
  end
end
