require 'measured'
require 'measured/web'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  [username, password] == [Measured::Config.auth_username, Measured::Config.auth_password]
end

run Measured::Web
