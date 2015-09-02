module XCSKarel
  module Application
    def self.choose_bot(server)
      all_bots = server.get_bots
      bot_names = all_bots.map { |json| "#{json['name']} (#{json['_id']})" }
      puts "Which Bot should be used as a template?"
      choice = choose(*bot_names)
      bot = all_bots[bot_names.index(choice)]
      XCSKarel.log.info "Chose Bot \"#{bot['name']}\""
      return bot
    end

    def self.save_bot(config_folder, bot, api_version)
      rand_name = XCSKarel::XCSFile.random_name
      config_name = ask("Config name (hit Enter to accept generated name \"" + "#{rand_name}".yellow + "\"): ")
      config_name = rand_name if config_name.length == 0
      
      # preprocess the config name first
      require 'uri'
      config_name = URI::escape(config_name.gsub(" ", "_"))

      real_name = "botconfig_#{config_name}.json"
      new_config_path = XCSKarel::XCSFile.new_config_name(config_folder, real_name)
      new_config = XCSKarel::Config.new(bot, api_version, new_config_path)
      new_config.save

      XCSKarel.log.info "Saved Bot \"#{new_config.name}\" configuration to #{new_config_path}. Check this into your repository.".green
      system "open \"#{new_config_path}\""
    end

    def self.list_configs(config_folder)
      configs = XCSKarel::XCSFile.load_configs(config_folder)
      if configs.count == 0
        XCSKarel.log.info "Found no existing configs in #{config_folder}".yellow
      else
        out = "\n" + configs.map { |c| "\"#{c.name}\"".yellow + " [#{File.basename(c.path)}]".yellow + " - from Bot " + "#{c.original_bot_name}".yellow }.join("\n")
        XCSKarel.log.info "Found #{configs.count} configs in \"#{config_folder}\":"
        XCSKarel.log.info out
      end
    end

    def self.show_config(config_folder)
      configs = XCSKarel::XCSFile.load_configs(config_folder)
      config_names = configs.map { |c| "Config " + "#{c.name}".yellow + " from Bot " + "#{c.original_bot_name}".yellow }
      puts "Which config?"
      choice = choose(*config_names)
      config = configs[config_names.index(choice)]
      XCSKarel.log.info "Editing config \"#{config.name}\""
      system "open \"#{config.path}\""
    end

    def self.colorize(key, value)
      value ||= ""
      case key
      when "integration_step"
        case value
        when "completed"
          value = value.white
        when "pending"
          value = value.blue
        else
          value = value.yellow
        end
      when "integration_result"
        case value
        when "succeeded"
          value = value.green
        when "canceled"
          value = value.yellow
        else
          value = value.red
        end
      end
      return value
    end

    def self.print_status(server)
      statuses = server.fetch_status
      require 'terminal-table'

      head = statuses.first.keys
      table = Terminal::Table.new do |t|
        statuses.each do |status|
          r = head.map { |h| self.colorize(h, status[h]) }
          t.add_row r
        end
      end
      table.title = server.host
      table.headings = head
      # table.style = {:width => 160}
      puts table.to_s
    end

    def self.integrate(server, bot_id_or_name)

      # find bot by id or name
      bot = server.find_bot_by_id_or_name(bot_id_or_name)
      XCSKarel.log.debug "Found Bot #{bot['name']} with id #{bot['_id']}".yellow

      # kick off an integration
      server.integrate(bot)

      # print the new status (TODO: highlight the bot's row)
      self.print_status(server)
    end

  end
end