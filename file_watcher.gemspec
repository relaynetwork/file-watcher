PKG_VERSION = '1.0.10'
$spec = Gem::Specification.new do |s|
  s.name = 'file-watcher'
  s.version = PKG_VERSION
  s.summary = 'Use inotify to watch for file system modifcations and take a configured action.'
  s.description = <<EOS
Use inotify to watch for file system modifcations and take a configured action.'
EOS

  s.files = %w[bin/watcher lib/file_watcher/watch_config.rb lib/file_watcher/watch_job.rb lib/file_watcher/log_helper.rb]
  s.executables = %w[watcher]
  s.require_paths = %w[bin lib]
  s.homepage = "https://github.com/relaynetwork/file-watcher"
  s.extra_rdoc_files = %w[README.textile]
  s.has_rdoc = false
  s.authors = ["Paul Santa Clara", "Josh Crean", "Kyle Burton"]
  s.email = "kburton@relaynetwork.com  "
  s.add_runtime_dependency('rb-inotify', '= 0.8.4')
  s.add_runtime_dependency('base_app', '>= 1.0.4')
  s.add_runtime_dependency('json', '>= 1.4.3')
end
