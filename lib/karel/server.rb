require 'excon'
require 'pry'
require 'karel/log'
require 'json'
require 'base64'

module xcskarel

  class Server

    attr_reader :host
    attr_reader :user
    attr_reader :pass
    attr_reader :port

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
      JSON.parse(response.body)['results']
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
      url = url_for_endpoint(endpoint)
      headers = self.headers || {}
      response = Excon.get(url, :headers => headers)
      xcskarel.log.debug "GET endpoint #{endpoint} => #{url} => Response #{response.data[:status_line].gsub("\n", "")}"
      return response
    end

    private

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
        raise "Failed to validate - #{e}.\nPlease make sure your Xcode Server is up and running at #{host}. Run `xcskarel server start` to start a new local Xcode Server instance.".red
      else
        raise "Failed to validate - Endpoint at \"#{url}\" responded with #{response.data[:status_line]}".red if response.status != 204
        xcskarel.log.debug "Validation of host #{@host} succeeded.".green
      end
    end
  end
end