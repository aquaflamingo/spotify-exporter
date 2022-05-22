# frozen_string_literal: true

module SpotifyExporter
  module Injectable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Dynamically defines a private method in the included class
      def inject(name, source)
        define_method(name.to_sym) { source.call }
        private name.to_sym
      end
    end
  end
end
