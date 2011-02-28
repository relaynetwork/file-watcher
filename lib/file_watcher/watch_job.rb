require File.join( File.dirname(__FILE__), 'watch_config')
require 'cgi'
require 'net/http'
require 'uri'

class WatchJob
  include WatchConfig
  attr_accessor :watch_criteria, :watch_action

  @@registered_jobs = []

  def self.registered_jobs
    @@registered_jobs 
  end


  def do_post event
    Net::HTTP.start(watch_action[:http][:hostname]) do |http|
      if watch_action[:http][:ssl] 
        protocol = 'https'
      else
        protocol = 'http'
      end

      url = "#{protocol}://#{watch_action[:http][:auth_user]}:#{watch_action[:http][:auth_pass]}@#{watch_action[:http][:hostname]}:#{watch_action[:http][:port]}#{watch_action[:http][:uri]}"


      body = watch_action[:http][:body].merge({ :args => watch_action[:http][:body][:args].dup.push(event.name) } )

      puts "URL: #{url}"
      puts "body: #{body}"

      res = Net::HTTP.post_form(URI.parse(url), {'body' => body.to_json } ) 
      puts "Response: #{res}"
    end
  end

  def event_handler event
    return unless event.name =~ watch_criteria[:file_glob]
       
    if watch_action.keys.first == :http && watch_action[:http][:method] == :post
      return do_post event
    end

    raise "Error: unsupported watch action in: #{watch_action.inspect}"
  end
end
