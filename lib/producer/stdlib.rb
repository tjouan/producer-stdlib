module Producer
  module STDLib
    class << self
      def define_macro(name, &block)
        ::Producer::Core::Recipe.define_macro(name, block)
      end

      def compose_macro(*args)
        ::Producer::Core::Recipe.compose_macro(*args)
      end

      def define_test(name, &block)
        ::Producer::Core::Condition.define_test(name, block)
      end
    end

    require 'producer/stdlib/fs'
    require 'producer/stdlib/debian'
    require 'producer/stdlib/freebsd'
    require 'producer/stdlib/freebsd/ports'
    require 'producer/stdlib/git'
    require 'producer/stdlib/ssh'
    require 'producer/stdlib/version'
    require 'producer/stdlib/yaml'
  end
end
