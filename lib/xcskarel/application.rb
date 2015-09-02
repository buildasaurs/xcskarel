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
  end
end