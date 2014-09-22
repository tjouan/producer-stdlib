module Producer
  module STDLib
    module FreeBSD
      module Ports
        STDLib.define_macro :port_install do |port, options = {}|
          make_args = []

          condition { no_pkg? port }

          make_args << '-DBATCH'

          %w[with without].each do |e|
            if options[e.to_sym]
              make_args << "#{e.upcase}='%s'" % options[e.to_sym].map(&:upcase).join(' ')
            end
          end

          sh "cd /usr/ports/#{port} && make #{make_args.join ' '} install clean"
        end

        STDLib.define_macro :portmaster do |port|
          condition { no_pkg? port }

          sh "portmaster -bDG --no-confirm #{port}"
        end
      end
    end
  end
end
