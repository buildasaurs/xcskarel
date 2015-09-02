module XCSKarel
  class Config
    attr_reader :json
    attr_reader :path
    attr_reader :api_version

    def initialize(json, api_version, path)
      @json = json
      @path = path
      @api_version = api_version || (config_json ? config_json['api_version'] : nil)
    end

    def name
      (config_json['name'] || File.basename(@path).split('.').first).gsub("botconfig_", "")
    end

    def branch
      blueprint = @json['configuration']['sourceControlBlueprint']
      primary_repo_key = blueprint['DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey']
      location = blueprint['DVTSourceControlWorkspaceBlueprintLocationsKey'][primary_repo_key]
      # might be nil if we're pointing to a commit, for instance.
      return location['DVTSourceControlBranchIdentifierKey']
    end

    def original_bot_name
      @json['name'] || config_json['original_bot_name']
    end

    def config_json
      @json['xcsconfig'] || {}
    end

    def key_paths_for_persistance
      key_paths_for_xcode_server << "xcsconfig"
    end

    def key_paths_for_xcode_server
      ["configuration"]
    end

    def format_version
      1
    end

    def json_for_persistence
      filtered = XCSKarel::Filter.filter_key_paths(@json, key_paths_for_persistance)

      # also add xcsconfig metadata
      unless filtered["xcsconfig"]
        filtered["xcsconfig"] = {
          format_version: format_version,
          app_version: XCSKarel::VERSION,
          original_bot_name: @json['name'],
          name: name,
          api_version: @api_version
        }
      end
      return filtered
    end

    def json_for_xcode_server
      XCSKarel::Filter.filter_key_paths(@json, key_paths_for_xcode_server)
    end

    def self.from_file(file_path)
      abs_path = File.absolute_path(file_path)
      raise "No file #{abs_path}" unless File.exist?(abs_path)
      config = self.new(JSON.parse(File.read(abs_path)), nil, abs_path)
      unless config.validate_loaded
        XCSKarel.log.warn "Skipping invalid config #{abs_path}".yellow
        return nil
      end
      return config
    end

    def validate_loaded
      return false unless config_json
      return true
    end

    def to_file(file_path)
      abs_path = File.absolute_path(file_path)
      raise "File #{abs_path} already exists. Choose a different name.".red if File.exist?(abs_path)
      FileUtils.mkdir_p(File.dirname(abs_path))
      File.open(abs_path, 'w') do |f|  
        f.puts JSON.pretty_generate(json_for_persistence) + "\n"
      end
    end

    def save
      to_file(@path)
    end
  end
end
