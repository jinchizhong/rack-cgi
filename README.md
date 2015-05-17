Rack::CGI
=========

Let you using CGI in your rack application.

Usage
-----

Here is an example for using Rack::CGI

    # config.ru

    use Rack::CGI, cgi_path: 'cgi', index: 'index.cgi', Rack::CGI::Executable => '', /\.php$/ => '/usr/bin/php-cgi'
    use Rack::Static, urls: ['/'], root: 'cgi'
    run proc{ [404, {"CONTENT-TYPE" => "text/plain"}, ['404 Not Found']] }

Howto
-----

### Document Root

In default, Rack::CGI will use Dir.pwd as document root, you can use `cgi_path: path` to change it.

### Index file

When user access directory, Rack::CGI will use index script instand of.

If you not special index, Rack::CGI will not have a default value, and it's not works.

You can special index as follow:

    use Rack::CGI, index: 'index.php'

    # or special multiple, Rack::CGI will try each by order
    use Rack::CGI, index: ['index.php', 'index.cgi']

### Rules 

When Rack::CGI found a script file in disk, it will try to find a rule to deal it.

You can special multiple rules, in follow format:

    use Rack::CGI, match1 => deal1, match2 => deal2, match3 => deal3 ...

`match` can be Rack::CGI::Executable or Regexp.  
Rack::CGI::Executable match all script that is executable.  
Regexp will try to match script full path.

If none rules match, Rack::CGI will do nothing. Such as if you spacial Rack::CGI::Executable => "", 
and your file is not executable, Rack::CGI will not tell you file cannot executable, but just skiped.

`deal` can be `nil`, `""`, `path_to_application`.  
If you special `nil`, nothing will happened, as if not matched.  
If you special `""`, script will be launched directly. Ensure script is executable.  
If you special `path_to_application`, application will be launched with script name.

### Directory redirect

In some programs(such as phpBB), when you visit a dir without ending '/'. (Such as 'http://wps-community.org/forum')
All relative resource will cannot accessed. In this case, we have to redirect 'http://wps-community.org/forum' to 
'http://wps-community.org/forum/' to avoid this problem.

You can use following code to open this feature.

    use Rack::CGI, ..., dir_redirect: true, ...

### Use Rack::CGI in Rails project

Originally I intended to write a project named rails-cgi.
But it's so trouble, and run Rack app in rails is not very complex.
So I give up rails-cgi.

1. Create a cgi controller

    $ rails g controller cgi

2. Create a Rack Application in CgiController

    # You can changed arguments as you want
    CGI = Rack::Builder.new do
      use Rack::CGI, cgi_path: 'cgi', index: ['index.cgi', 'index.php'], Rack::CGI::Executable => '', /\.php$/ => '/usr/bin/php-cgi'
      use Rack::Static, urls: ['/'], root: 'cgi'
      run proc{ |env| raise ActionController::RoutingError, env['PATH_INFO'] + " not found!" }
    end

3. Call Rack App in rails controller

    # add an action to controller
    def cgi
      [self.status, self.response.headers, self.response_body] = CGI.call env
    end
    # of course, you can add decoration code here, such as call rails layout

4. Add route

    # add follow to config/routes.rb
    get '/cgi-bin/*path' => 'cgi#cgi'

TODO
----

POST Request support
