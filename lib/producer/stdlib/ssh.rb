module Producer
  module STDLib
    module SSH
      require 'base64'

      SSH_AUTHORIZED_KEYS_PATH  = '.ssh/authorized_keys'.freeze
      SSH_AUTHORIZED_NO_KEY_FMT =
        '"ssh_authorize macro cannot find key matching `%s\''


      STDLib.define_macro :ssh_dir do
        condition { no_dir? '.ssh' }

        mkdir '.ssh', 0700
      end

      STDLib.define_macro :ssh_authorize do |key_pattern, user: nil|
        path_base = user ? '/home/%s' % user : nil
        path      = Pathname.new(path_base) + SSH_AUTHORIZED_KEYS_PATH

        condition { no_file? path }

        if condition_met?
          key = Net::SSH::Authentication::Agent.connect.identities.find do |e|
            e.fingerprint =~ /\A#{key_pattern}/
          end

          fail Core::RuntimeError, SSH_AUTHORIZED_NO_KEY_FMT % key_pattern unless key

          line = [
            key.ssh_type,
            ::Base64.encode64(key.to_blob).gsub("\n", '')
          ].join ' '

          ensure_dir path.dirname, 0700
          file_write_once path, "#{line}\n", 0600
          sh 'chown -R %s %s' % [user, path.dirname] if user
        end
      end

      STDLib.define_macro :ssh_copy_id do |path = SSH_AUTHORIZED_KEYS_PATH|
        condition { no_file? path }

        if condition_met?
          agent = Net::SSH::Authentication::Agent.connect
          choices = agent.identities.map { |e| [e, e.comment] }
          key = ask 'Which key do you want to copy?', choices

          line = [
            key.ssh_type,
            ::Base64.encode64(key.to_blob).gsub("\n", '')
          ].join ' '

          file_write path, "#{line}\n", 0600
        end
      end
    end
  end
end
