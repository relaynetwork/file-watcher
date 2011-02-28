module WatchConfig

  def self.included base
    base.extend( ClassMethods)
  end

  module ClassMethods
    def validate_new_job wj
      raise "Error: Watch job is missing watch dir: #{wj.inspect}" unless wj.watch_criteria.keys.include? :target_dir

      raise "Error: Watch directory doesn't exist: #{wj.watch_criteria[:target_dir]}" unless File.exist? wj.watch_criteria[:target_dir]

      raise "Error: Watch configuration did not specify any events to watch for (#{wj.inspect})" if wj.watch_criteria[:events].empty?


      raise "Error: Only http watch actions are supported: #{wj}" unless wj.watch_action.keys == [:http]

      raise "Error: Invalid/Unsupported http method [#{wj.watch_action[:http][:method]}] in config [#{wj.watch_action.inspect}]" unless wj.watch_action[:http][:method] == :post
    end

    def new_watch_job &block
      wj = WatchJob.new 

      yield wj

      validate_new_job wj 
      self.registered_jobs << wj
    end 

  end

end


