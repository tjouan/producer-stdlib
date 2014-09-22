module Producer
  module STDLib
    module SSH
      require 'base64'

      SSH_AUTHORIZED_KEYS_PATH = '.ssh/authorized_keys'.freeze


      STDLib.define_macro :ssh_dir do
        condition { no_dir? '.ssh' }

        mkdir '.ssh', 0700
      end

      STDLib.define_macro :ssh_copy_id do |path = SSH_AUTHORIZED_KEYS_PATH|
        condition { no_file? path }

        # FIXME: remove this hack, should have proper keyword or another way
        if !!condition
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
