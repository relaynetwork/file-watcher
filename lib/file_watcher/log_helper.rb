require 'logger'
$Logger = Logger.new(STDOUT)

module LogHelper
  def log msg, level='info'
      $Logger.send( level, msg )    
  end
end
