require '../lib/rack-cgi'

use Rack::CGI, cgi_path: 'cgi', index: 'index.cgi', Rack::CGI::Executable => '', /\.php$/ => '/usr/bin/php-cgi'
use Rack::Static, urls: ['/'], root: 'cgi'
run proc{ [404, {"CONTENT-TYPE" => "text/plain"}, ['404 Not Found']] }
