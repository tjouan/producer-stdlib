module Producer
  module STDLib
    module Debian
      STDLib.define_test(:apt_pkg?) do |pkg|
        sh "dpkg-query -l #{pkg} > /dev/null 2>&1"
      end

      STDLib.define_macro :apt_install do |pkg|
        condition { no_apt_pkg? pkg }

        sh "env DEBIAN_FRONTEND=noninteractive apt-get install --quiet --yes #{pkg}"
      end
    end
  end
end
