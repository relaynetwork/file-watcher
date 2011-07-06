require File.join( File.dirname(__FILE__), 'watch_config')
require 'cgi'
require 'net/http'
require 'net/https'
require 'uri'
require File.join( File.dirname(__FILE__), 'log_helper')

class WatchJob
  include WatchConfig
  include LogHelper
  attr_accessor :watch_criteria, :watch_action

  @@registered_jobs = []

  def self.registered_jobs
    @@registered_jobs 
  end

  def do_post event
    if watch_action[:http][:ssl] 
      protocol = 'https'
    else
      protocol = 'http'
    end

    url = "#{protocol}://#{watch_action[:http][:hostname]}:#{watch_action[:http][:port]}#{watch_action[:http][:uri]}"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    if watch_action[:http][:ssl] 
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    file_suffix = event.name.match(/(\d{2})\./)[1]

    body = watch_action[:http][:body].merge({ :args => watch_action[:http][:args].call().push(event.name).push(file_suffix) } )

    log "URL: #{url}"
    log "body: #{body.to_json}"

    log "Path: #{uri.path}"
    log "URI: #{uri.inspect}"
    log "Port: #{uri.port}"

    req = Net::HTTP::Post.new(uri.path)
    if watch_action[:http][:auth_user]
      log "Setting auth..."
      req.basic_auth watch_action[:http][:auth_user], watch_action[:http][:auth_pass]
    end

    req.set_form_data({'body' => body.to_json })
    log "SENDING: #{req.inspect}"
    res = http.request(req)
    log "Res: #{res.inspect}"
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      log "Req was ok"
    else
      res.error!
    end

    log "Response: #{res}"
  end

  def event_handler event
    return if watch_criteria[:file_glob] && !event.name =~ watch_criteria[:file_glob]
      
    if watch_action.keys.first == :http && watch_action[:http][:method] == :post
      return do_post event
    end

    raise "Error: unsupported watch action in: #{watch_action.inspect}"
  end
end
