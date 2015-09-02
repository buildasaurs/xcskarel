require 'excon'
require 'xcskarel/log'
require 'json'
require 'base64'

module XCSKarel

  class Server

    attr_reader :host
    attr_reader :user
    attr_reader :pass
    attr_reader :port
    attr_reader :api_version

    def initialize(host, user=nil, pass=nil, allow_self_signed=true)
      @port = 20343
      @host = validate_host(host)
      @user = user
      @pass = pass
      validate_connection(allow_self_signed)
    end

    def get_bots
      response = get_endpoint('/bots')
      raise "You are unauthorized to access data on #{@host}, please check that you're passing in a correct username and password.".red if response.status == 401
      raise "Failed to fetch Bots from Xcode Server at #{@host}, response: #{response.status}: #{response.body}.".red if response.status != 200
      bots = JSON.parse(response.body)['results']

      # sort them alphabetically by name
      bots.sort_by { |bot| bot['name'] }
    end

    def get_integrations(bot_id)
      response = get_endpoint("/bots/#{bot_id}/integrations")
      raise "Failed to fetch Integrations for Bot #{bot_id} from Xcode Server at #{@host}, response: #{response.status}: #{response.body}".red if response.status != 200
      JSON.parse(response.body)['results']
    end

    def get_health
      response = get_endpoint("/health")
      raise "Failed to get Health of #{@host}" if response.status != 200
      JSON.parse(response.body)
    end

    def fetch_status
      # all bots and their integration's statuses
      bot_statuses = []
      bots = self.get_bots
      bots.map do |bot|
        status = {}
        status['name'] = bot['name']
        status['id'] = bot['_id']
        status['branch'] = XCSKarel::Config.new(bot, nil, nil).branch
        last_integration = self.get_integrations(bot['_id']).first # sorted from newest to oldest
        if last_integration
          status['current_step'] = last_integration['currentStep']
          status['result'] = last_integration['result']
          status['count'] = last_integration['number']
        else
          status['count'] = 0
        end
        bot_statuses << status
      end
      return bot_statuses
    end

    def integrate(bot)
      response = post_endpoint("/bots/#{bot['_id']}/integrations", nil)
      integration = response.body
      if response.status == 201
        require 'json'
        integration = JSON.parse(integration)
        XCSKarel.log.info "Successfully started integration #{integration['number']} on Bot \"#{bot['name']}\"".green
      else
        raise "Failed to integrate Bot #{bot_id}".red
      end
      return integration
    end

    def find_bot_by_id_or_name(id_or_name)
      bots = self.get_bots
      found_bots = bots.select { |bot| [bot['name'], bot['_id']].index(id_or_name) != nil }
      raise "No Bot found for \"#{id_or_name}\"".red if found_bots.count == 0
      XCSKarel.log.warn "More than one Bot found for \"#{id_or_name}\", taking the first one (you shouldn't have more Bots with the same name!)".red if found_bots.count > 1
      return found_bots.first
    end

    def headers
      headers = {
        'user-agent' => 'xcskarel', # XCS wants user agent. for some API calls. not for others. sigh.
        'X-XCSAPIVersion' => 6 # XCS API version with this API, currently 6 with Xcode 7 Beta 6.
      }

      if @user && @pass
        userpass = "#{@user}:#{@pass}"
        headers['Authorization'] = "Basic #{Base64.strict_encode64(userpass)}"
      end

      return headers
    end

    def get_endpoint(endpoint)
      call_endpoint("get", endpoint, nil)
    end

    def post_endpoint(endpoint, body)
      call_endpoint("post", endpoint, body)
    end

    private

    def call_endpoint(method, endpoint, body)
      method.downcase!
      url = url_for_endpoint(endpoint)
      case method
      when "get"
        response = Excon.get(url, headers: headers)
      when "post"
        response = Excon.post(url, headers: headers, body: body)
      else
        raise "Unrecognized method #{method}"
      end
      msg = "#{method.upcase} endpoint #{endpoint} => #{url} => Response #{response.data[:status_line].gsub("\n", "")}"

      case response.status
      when 200..300
        XCSKarel.log.debug msg.green
      else
        XCSKarel.log.warn msg.red
      end
      return response
    end

    def url_for_endpoint(endpoint)
      "#{@host}:#{@port}/api#{endpoint}"
    end

    def validate_host(host)
      comps = host.split(":")
      raise "Scheme must be unspecified or https, nothing else" if comps.count > 1 && comps[0] != 'https'
      host_with_https = comps.count > 1 ? host : "https://#{host}"
      return host_with_https
    end

    def validate_connection(allow_self_signed)

      # check for allowing self-signed certs
      Excon.defaults[:ssl_verify_peer] = !allow_self_signed

      # TODO: logout/login to validate user/pass

      # try to connect to the host
      begin
        response = get_endpoint("/ping")
      rescue Exception => e
        raise "Failed to validate - #{e}.\nPlease make sure your Xcode Server is up and running at #{@host}. Run `xcskarel server start` to start a new local Xcode Server instance.".red
      else
        raise "Failed to validate - Endpoint responded with #{response.data[:status_line]}".red if response.status != 204
        @api_version = response.headers['X-XCSAPIVersion'].to_s
        XCSKarel.log.debug "Validation of host #{@host} (API version #{@api_version}) succeeded.".green
      end
    end
  end
end