module XCSKarel
  module XCSFile
    def self.folder_name
      "xcsconfig"
    end

    def self.file_name
      "xcsfile.json"
    end

    def self.find_config_folder_in_current_folder
      self.find_config_folder_in_folder(Dir.pwd)
    end

    def self.find_config_folder_in_folder(folder)
      # look for the xcsconfig folder with an xcsfile inside
      abs_folder = File.absolute_path(folder)
      found_folder = Dir[File.join(abs_folder, "/", "*")].select do |f|
        File.basename(f) == self.folder_name
      end.first
      return found_folder
    end

    def self.create_config_folder_in_current_folder
      self.create_config_folder_in_folder(Dir.pwd)
    end

    def self.create_config_folder_in_folder(folder)
      abs_folder = File.absolute_path(folder)
      config_folder = File.join(abs_folder, self.folder_name)
      FileUtils.mkdir_p(config_folder)
      return config_folder
    end

    def self.get_config_folder
      config_folder = XCSKarel::XCSFile.find_config_folder_in_current_folder
      unless config_folder
        should_create = agree("There is no xcsconfig folder found, should I create one for you? (y/n)".red)
        if should_create
          config_folder = XCSKarel::XCSFile.create_config_folder_in_current_folder unless config_folder
          XCSKarel.log.debug "Folder #{config_folder} created".yellow
        else
          return nil
        end
      end
      # we have a config folder
      XCSKarel.log.debug "Config folder found: #{config_folder}".green
      return config_folder
    end

    def self.load_configs(folder)
      require 'json'
      Dir[File.join(folder, "/", "botconfig_*.json")].map do |f|
        XCSKarel::Config.from_file(f)
      end.select do |c|
        c != nil
      end
    end

    def self.random_name
      require 'securerandom'
      "#{SecureRandom.hex(6)}"
    end

    def self.new_config_name(folder, name)
      name = name.split('.').first + ".json"
      File.join(folder, name)
    end

  end
end