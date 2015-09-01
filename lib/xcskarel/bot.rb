module XCSKarel
  class Bot
    attr_reader :json
    def initialize(json)
      @json = json
    end

    def self.from_file(file_path)
      abs_path = File.absolute_path(file_path)
      raise "No file #{abs_path}" unless File.exist?(abs_path)
      self.new(File.read(abs_path))
    end

    def to_file(file_path="./xcskarel/bot.json")
      abs_path = File.absolute_path(file_path)
      raise "File #{abs_path} already exists." if File.exist?(abs_path)
      FileUtils.mkdir_p(File.dirname(abs_path))
      File.open(abs_path, 'w') do |f|  
        f.puts JSON.pretty_generate(@json) + "\n"
      end  
    end
  end
end
