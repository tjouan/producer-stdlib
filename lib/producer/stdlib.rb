module Producer
  module STDLib
    class << self
      def define_macro(name, &block)
        ::Producer::Core::Recipe::DSL.define_macro(name, block)
      end

      def define_test(name, &block)
        ::Producer::Core::Condition::DSL.define_test(name, block)
      end
    end

    require 'producer/stdlib/fs'
    require 'producer/stdlib/freebsd'
    require 'producer/stdlib/freebsd/ports'
    require 'producer/stdlib/git'
    require 'producer/stdlib/ssh'
    require 'producer/stdlib/version'
  end
end
