Gem::Specification.new do |s|
  s.name         = 'rack-cgi'
  s.version      = '0.2'
  s.date         = '2015-05-17'
  s.summary      = 'A rack middleware that can call CGI in rack'
  s.description  = 'A rack middleware that can call CGI in rack'
  s.authors      = ['Chizhong Jin']
  s.email        = 'jinchizhong@kingsoft.com'
  s.files        = Dir['{lib/*,lib/**/*,test/*,test/**/*}'] + 
                      %w(rack-cgi.gemspec)
  s.homepage     = 'http://rubygems.org/gems/rack-cgi'
  s.license      = 'BSD'

  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'childprocess'

  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'rake-test'
end
