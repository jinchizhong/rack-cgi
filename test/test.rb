ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack'
require 'rack/test'

class RackCgiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    Dir.chdir File.dirname(File.expand_path(__FILE__))
  end

  def app
    s, c = Rack::Builder.parse_file "./config.ru"
    s
  end

  def res
    last_response
  end

  def test_cgi_index
    get '/'
    assert res.ok?
    assert_equal res.body, "Hello world\n"
    assert_equal res.headers['Content-Type'], 'text/plain'
  end

  def test_cgi_error
    get '/error'
    assert !res.ok?
    assert_equal res.status, 500
    assert_equal res.body, "500 Server Internal Error\n"
  end

  def test_cgi_export
    get '/export'
    assert res.ok?
    
    body = res.body
    h = {}
    body.lines.each do |line|
      line = line.sub /^export /, ''
      k, v = line.split '='
      h[k] = v
    end
    assert_equal h['SCRIPT_FILENAME'], "'" + Dir.pwd + "/cgi/export'\n"
  end

  def test_cgi_file
    get '/file'
    assert res.ok?

    assert_equal res.body, "This is a test file for test\n"
  end

  def test_cgi_redirect
    get '/redirect'
    assert_equal res.status, 302
    assert_equal res.headers['Location'], 'http://www.google.com'
  end

  def test_cgi_php
    if !File.exists? '/usr/bin/php-cgi'
      puts 'php-cgi not found, skip php-cgi test!'
    end
    get '/test.php'
    assert res.ok?
  end
  
  def test_without_header
    get '/without_header'
    assert_equal res.body, "Hello world\n"
  end

  def test_dir_redirect
    get '/something'
    assert_equal res.status, 302
  end

  def test_no_redirect_without_index
    get '/nothing'
    assert_equal res.status, 404
  end
end
