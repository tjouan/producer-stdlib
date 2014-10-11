module Producer
  module STDLib
    module YAML
      STDLib.define_macro :yaml_write_once do |path, data, options = {}|
        condition { no_yaml_eq path, data }

        yaml_write path, options.merge(data: data)
      end
    end
  end
end
