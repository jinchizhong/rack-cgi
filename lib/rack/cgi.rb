require 'childprocess'

module Rack
  class CGI
    class Executable
      def self.=~ rhs
        ::File.executable? rhs
      end
    end

    def initialize app, args = {}
      @app = app
      @opts = args.select {|k, _| k.is_a? Symbol}
      @rules = args.select {|k, _| !k.is_a? Symbol}

      @root = @opts[:cgi_path]
      if @root !~ /^\//
        @root = ::File.join(Dir.pwd, @root)
      end

      @index = @opts[:index] || []
      @index = [@index] if not @index.is_a? Hash
    end

    def solve_path path
      path = ::File.join(@root, path)
      if ::File.directory? path
        @index.each do |f|
          path2 = ::File.join(path, f)
          return path2 if ::File.file? path2
        end
      else
        return path if ::File.file? path
      end
      nil
    end

    def cgi_env env, path
      env = env.select {|k, _| k =~ /^[A-Z]/}
      env['SCRIPT_FILENAME'] = path
      env['DOCUMENT_ROOT'] = @root
      env['REDIRECT_STATUS'] = "200"
      env
    end

    def match_cgi_rule path
      @rules.each do |m, r|
        if m =~ path
          return r
        end
      end
      return nil
    end

    def run_cgi rule, path, env
      if rule.empty?
        args = [path]
      else
        args = [rule, path]
      end

      process = ChildProcess.build(*args)
      process.io.stdout = Tempfile.new('rack-cgi-stdout')
      process.io.stderr = Tempfile.new('rack-cgi-stderr')
      env.each do |k, v|
        process.environment[k] = v
      end
      process.cwd = Dir.pwd
      process.start
      process.wait

      cont_out = ::File.read(process.io.stdout.path)
      cont_err = ::File.read(process.io.stderr.path)
      process.io.stdout.unlink
      process.io.stderr.unlink

      [process.exit_code, cont_out, cont_err]
    end

    def split_header_content output
      lines = output.lines.to_a
      header = []
      
      until lines.empty? 
        l = lines.shift
        if l == "\n" or l == "\r\n"
          # find break line between header and content
          return header.join, lines.join
        elsif l =~ /:/
          header << l
        else
          # content break header ruler, so deal as no header
          return "", output
        end
      end

      # deal all content as header
      return output, ""
    end

    def parse_output output
      header, content = split_header_content output
     
      h = {}
      header.each_line do |l|
        k, v = l.split ':', 2
        k.strip!
        v.strip!
        h[k.downcase] = [k, v]
      end

      if h['status']
        status = h['status'][1].to_i
        h.delete 'status'
      else
        status = 200
      end

      header_hash = Hash[h.values]

      [status, header_hash, [content]]
    end

    def report_error code, out, err, cgi_env
      h = {'Content-Type' => 'text/plain'}
      status = 500
      reports = []
      
      reports << "CGI Error!\n\n"
      reports << "stdout output:\n"
      reports << out
      reports << "\n"
      reports << "stderr output:\n"
      reports << err
      reports << "\n"
      reports << "environments:\n"
      cgi_env.each do |k, v|
        reports << "#{k} => #{v}\n"
      end

      [status, h, reports]
    end

    def call(env)
      path = solve_path env["PATH_INFO"]
      if not path
        return @app.call(env)
      end

      rule = match_cgi_rule path
      if not rule
        return @app.call(env)
      end

      cgi_env = cgi_env(env, path)
      code, out, err = run_cgi rule, path, cgi_env
      if code == 0
        parse_output out
      else
        report_error code, out, err, cgi_env
      end
    end
  end
end

