require 'json'
require 'producer/stdlib/json/json_eq'

module Producer
  module STDLib
    module JSON
      #STDLib.define_test :json_eq do |path, data|
      #  file_eq path, ::JSON.generate(data)
      #end
      STDLib.define_test :json_eq, JSONEq

      STDLib.define_macro :json_write do |path, data|
        file_write path, ::JSON.generate(data)
      end

      STDLib.define_macro :json_write_once do |path, data|
        condition { no_json_eq path, data }
        json_write path, data
      end
    end
  end
end
