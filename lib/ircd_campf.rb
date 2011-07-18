$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../../ircd_slim/lib"))

require 'firering'
require 'ircd_slim'

module IRCDCampf
  VERSION = "0.0.1"

  autoload :Bridge, "ircd_campf/bridge"
end
