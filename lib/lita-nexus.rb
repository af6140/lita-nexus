require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require 'nexushelper/remote'
require "lita/handlers/nexus"

Lita::Handlers::Nexus.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
