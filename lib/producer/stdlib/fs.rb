module Producer
  module STDLib
    module FS
      STDLib.define_macro :ensure_dir do |path, mode|
        mode ||= 0700

        condition { no_dir? path }

        mkdir path, mode
      end

      STDLib.define_macro :file_append_once do |path, content|
        condition { no_file_contains path, content }

        file_append path, content
      end

      STDLib.define_macro :file_write_once do |path, content|
        condition { no_file_eq path, content }

        file_write path, content
      end
    end
  end
end
