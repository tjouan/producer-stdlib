module Producer
  module STDLib
    module FreeBSD
      require 'shellwords'

      LOADER_CONF_PATH    = '/boot/loader.conf'.freeze
      RC_CONF_PATH        = '/etc/rc.conf'.freeze
      SYSCTL_CONF_PATH    = '/etc/sysctl.conf'.freeze
      PERIODIC_CONF_PATH  = '/etc/periodic.conf'.freeze
      MAKE_CONF_PATH      = '/etc/make.conf'.freeze


      STDLib.compose_macro :loader_conf, :file_write_once, LOADER_CONF_PATH

      STDLib.compose_macro :rc_conf, :file_write_once, RC_CONF_PATH
      STDLib.compose_macro :rc_conf_append, :file_append_once, RC_CONF_PATH

      STDLib.compose_macro :sysctl_conf, :file_write_once, SYSCTL_CONF_PATH

      STDLib.compose_macro :periodic_conf,
        :file_write_once, PERIODIC_CONF_PATH
      STDLib.compose_macro :periodic_conf_append,
        :file_append_once, PERIODIC_CONF_PATH

      STDLib.compose_macro :make_conf, :file_write_once, MAKE_CONF_PATH

      STDLib.define_test :rc_conf? do |key, value|
        file_contains '/etc/rc.conf', "#{key}=#{value}\n"
      end

      STDLib.define_test :rc_enabled? do |service|
        sh "service #{service} enabled > /dev/null"
      end

      STDLib.define_macro :rc_conf_update do |key, value|
        condition { no_rc_conf? key, value }

        file_replace_content RC_CONF_PATH, /^#{key}=.+$/, "#{key}=#{value}"
      end

      # FIXME: should update existing values
      STDLib.define_macro :rc_conf_add do |attributes|
        attributes.each do |k, v|
          value = case v
          when true   then '"YES"'
          when false  then '"NO"'
          else '"%s"' % v
          end

          file_append_once RC_CONF_PATH, "#{k}=#{value}\n"
        end
      end

      STDLib.define_macro :rc_enable do |service|
        condition { no_rc_enabled? service }

        file_append RC_CONF_PATH, %{\n#{service}_enable="YES"\n}
        sh "service #{service} start"
      end

      STDLib.define_macro :rc_disable do |service|
        condition { rc_enabled? service }

        rc_conf_update "#{service}_enable", '"NO"'
      end

      STDLib.define_macro :rc_send do |command, service|
        sh "service #{service} #{command}"
      end

      STDLib.compose_macro :rc_status,  :rc_send, 'status'
      STDLib.compose_macro :rc_reload,  :rc_send, 'reload'
      STDLib.compose_macro :rc_restart, :rc_send, 'restart'
      STDLib.compose_macro :rc_start,   :rc_send, 'start'
      STDLib.compose_macro :rc_stop,    :rc_send, 'stop'

      STDLib.compose_macro :hostname, :rc_conf_update, 'hostname'

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
        sh "env PACKAGESITE=#{repo_uri} SIGNATURE_TYPE=NONE ASSUME_ALWAYS_YES=YES pkg bootstrap"
        sh "env PACKAGESITE=#{repo_uri} pkg update"
      end

      STDLib.define_macro :pkg_install do |pkg|
        condition { no_pkg? pkg }

        sh 'pkg install -y %s' % pkg
      end
    end
  end
end
