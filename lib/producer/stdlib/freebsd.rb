module Producer
  module STDLib
    module FreeBSD
      require 'shellwords'

      LOADER_CONF_PATH    = '/boot/loader.conf'.freeze
      RC_CONF_PATH        = '/etc/rc.conf'.freeze
      SYSCTL_CONF_PATH    = '/etc/sysctl.conf'.freeze
      PERIODIC_CONF_PATH  = '/etc/periodic.conf'.freeze
      MAKE_CONF_PATH      = '/etc/make.conf'.freeze


      STDLib.define_test(:rc_enabled?) do |service|
        sh "service #{service} enabled > /dev/null"
      end

      STDLib.define_macro :rc_enable do |service|
        condition { no_rc_enabled? service }

        file_append RC_CONF_PATH, %{\n#{service}_enable=\"YES\"\n}
        sh "service #{service} start"
      end

      STDLib.define_macro :hostname do |hostname|
        rc_conf_value = "hostname=#{hostname}"

        condition { no_file_contains RC_CONF_PATH, rc_conf_value }

        file_replace_content RC_CONF_PATH, /^hostname=.+$/, rc_conf_value
      end

      # FIXME: refactor with file_add macro?
      STDLib.define_macro :loader_conf do |conf|
        condition { no_file_contains LOADER_CONF_PATH, conf }

        file_append LOADER_CONF_PATH, "\n%s" % conf
      end

      # FIXME: refactor with file_add macro?
      STDLib.define_macro :rc_conf do |conf|
        condition { no_file_contains RC_CONF_PATH, conf }

        file_append RC_CONF_PATH, "\n%s" % conf
      end

      # FIXME: refactor with file_add macro?
      STDLib.define_macro :sysctl_conf do |conf|
        condition { no_file_contains SYSCTL_CONF_PATH, conf }

        file_append SYSCTL_CONF_PATH, "\n%s" % conf
      end

      # FIXME: refactor with file_add macro?
      STDLib.define_macro :periodic_conf do |conf|
        condition { no_file_contains PERIODIC_CONF_PATH, conf }

        file_append PERIODIC_CONF_PATH, "\n%s" % conf
      end

      # FIXME: refactor with file_add macro?
      STDLib.define_macro :ports_config do |config|
        condition { no_file_contains MAKE_CONF_PATH, config }

        file_write MAKE_CONF_PATH, config
      end

      STDLib.define_macro :chsh do |shell|
        condition { no_env? :shell, shell }

        sh "chsh -s #{shell}"
      end

      STDLib.define_macro :group_add do |group, gid = nil|
        condition do
          no_sh "getent group #{group}"
          no_sh "getent group #{gid}" if gid
        end

        cmd = "pw group add #{group}"
        cmd << " -g #{gid}" if gid

        sh cmd
      end

      STDLib.define_macro :user_add do |user, opts = {}|
        options = {
          mask:   '0700',
          skel:   '/var/empty',
          shell:  '/bin/sh',
          pass:   'random'
        }.merge opts
        switches = {
          uid:    ?u,
          name:   ?c,
          group:  ?g,
          groups: ?G,
          mask:   ?M,
          skel:   ?k,
          shell:  ?s,
          pass:   ?w
        }

        condition do
          no_sh "getent passwd #{user}"
          no_sh "getent passwd #{options[:uid]}" if options[:uid]
        end

        cmd = switches.inject("pw user add #{user} -m") do |m, (k, v)|
          m << " -#{v} #{::Shellwords.escape(options[k])}" if options[k]
          m
        end

        sh cmd
      end

      STDLib.define_test(:pkg?) { |pkg| sh "pkg info -eO #{pkg}" }

      STDLib.define_macro :pkg_bootstrap do |repo_uri|
        condition { no_sh 'pkg -N' }

        # FIXME: must not disable signature
        sh "PACKAGESITE=#{repo_uri} SIGNATURE_TYPE=NONE ASSUME_ALWAYS_YES=YES pkg bootstrap"
        sh "PACKAGESITE=#{repo_uri} pkg update"
      end

      STDLib.define_macro :pkg_install do |pkg|
        condition { no_pkg? pkg }

        sh 'ASSUME_ALWAYS_YES=YES pkg install %s' % pkg
      end
    end
  end
end
