module Crepe
  module Middleware
    class ContentNegotiation

      ACCEPT_HEADER = %r{
        (?<type>[^/;,\s]+)
          /
        (?:
          (?:
            (?:vnd\.)?
            (?<vendor>[^/;,\s\.+]+)\.
            (?<version>[^/;,\s\.+]+)
            (?:\+)?
          )?
          (?<format>[^/;,\s\.+]+)
        )
      }ix

      MIME_TYPES = {
        'application/json' => :json,
        'application/xml'  => :xml
      }

      def initialize app
        @app = app
      end

      def call env
        if accept = ACCEPT_HEADER.match(env['HTTP_ACCEPT'])
          path = env['crepe.original_path_info'] = env['PATH_INFO']

          if accept[:vendor]
            env['crepe.vendor'] = accept[:vendor]
          end

          if accept[:version]
            path = ::File.join '/', accept[:version], path
          end

          if accept[:format]
            env['HTTP_ACCEPT'] = [accept[:type], accept[:format]].join '/'

            if ::File.extname(path).empty?
              if extension = MIME_TYPES[env['HTTP_ACCEPT']]
                path += ".#{extension}"
              end
            end
          end

          env['PATH_INFO'] = path
        end

        @app.call env
      end

    end
  end
end
