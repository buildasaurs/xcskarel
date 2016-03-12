require 'xcskarel/filter'
require 'json'

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
      when "current_step"
        case value
        when "completed"
          value = value.white
        when "pending"
          value = value.blue
        else
          value = value.yellow
        end
      when "result"
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

    def self.integrations(server, bot_id_or_name)
      bot = server.find_bot_by_id_or_name(bot_id_or_name)
      XCSKarel.log.debug "Found Bot #{bot['name']} with id #{bot['_id']}".yellow
      server.get_integrations(bot['_id'])
    end

    def self.delete_bot(server, bot_id_or_name)
      bot = server.find_bot_by_id_or_name(bot_id_or_name)
      XCSKarel.log.debug "Found Bot #{bot['name']} with id #{bot['_id']}".yellow
      server.delete_bot(bot)
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

    def self.issues(server, bot_id_or_name, integration_id)
      integration = nil
      if bot_id_or_name
        bot = server.find_bot_by_id_or_name(bot_id_or_name)
        # fetch last integration
        integration = (server.get_integrations(bot['_id']).first || {})['_id']
        raise "No Integration found for Bot \"#{bot['name']}\"".red unless integration
      else
        integration = server.get_integration(integration_id)['_id']
        raise "No Integration found for id #{integration_id}".red unless integration
      end

      # fetch issues
      issues = server.get_issues(integration)
      return issues
    end

    def self.format(object, options, allowed_key_paths, allow_empty_container_leaves=true)
      unless options.no_filter

        extra_filters = []

        unless allow_empty_container_leaves
          # optionally add an override to filter out empty containers as leaves
          empty_leaves = lambda do |k,v|
            return true unless v.is_a?(Array) || v.is_a?(Hash)
            return v.count > 0
          end
          extra_filters << empty_leaves
        end

        # create a super-filter composed from all the gathered filters
        custom_filters = lambda do |k,v|
          extra_filters.each do |filter|
            return false unless filter.call(k,v)
          end
          return true
        end

        object = XCSKarel::Filter.filter_key_paths(object, allowed_key_paths, custom_filters)
      end
      out = options.no_pretty ? JSON.generate(object) : JSON.pretty_generate(object)
      return out
    end

    def self.remote_logs(connection)
      logs_path = "/Library/Developer/XcodeServer/Logs"
      log_control = File.join(logs_path, "xcscontrol.log")
      log_build = File.join(logs_path, "xcsbuildd.log")
      lives = []
      [log_control, log_build].each do |log|
        puts "\n\n------- Printing output of #{log} at #{connection.host} -------\n".green
        res = connection.execute("tail -n 20 #{log}")
        puts res.yellow
        live = "ssh #{connection.user}@#{connection.host} tail -f #{log}".green
        lives << live
      end
      live_all = lives.map { |l| "\"#{l}\"" }.join("\n")
      XCSKarel.log.info "To connect to the logs live run either:\n#{live_all}"
    end

  end
end