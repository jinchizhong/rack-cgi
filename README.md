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

`match` can not Rack::CGI::Executable or Regexp. 
Rack::CGI::Executable means script file with '+x' property.
Regexp will try to match scriptname.

If none rules match, Rack::CGI will do nothing. Such as if you spacial Rack::CGI::Executable => "", 
and your file do not have a '+x' property, Rack::CGI will not tell you file cannot executable, but just skiped.

`deal` can be `nil`, "", `path_to_application`.  
If you special `nil`, nothing will happened.  
If you special "", script will be runned directly.  
If you special `path_to_application`, application will be launched with script name.

TODO
----

POST Request support
