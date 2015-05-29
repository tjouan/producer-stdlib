module Producer
  module STDLib
    module JSON
      class JSONEq < Core::Test
        def verify
          return false unless file_content = fs.file_read(arguments.first)
          ::JSON.parse(file_content, symbolize_names: true) == arguments[1]
        rescue ::JSON::ParserError
          false
        end
      end
    end
  end
end
