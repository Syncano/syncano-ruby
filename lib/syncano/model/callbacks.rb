module Syncano
  module Model
    # Module with callbacks functionality for Syncano::ActiveRecord
    module Callbacks
      extend ActiveSupport::Concern

      included do
        # Defines chains for all types of callbacks
        [:validation, :save, :create, :update, :destroy].each do |action|
          [:before, :after].each do |type|
            chain_name = "#{type}_#{action}_callbacks"
            class_attribute chain_name
          end
        end
      end

      # Class methods for Syncano::ActiveRecord::Callbacks module
      module ClassMethods
        private

        [:validation, :save, :create, :update, :destroy].each do |action|
          [:before, :after].each do |type|
            define_method("prepend_#{type}_#{action}") do |argument|
              send("#{type}_#{action}_callbacks").unshift(argument)
            end

            define_method("#{type}_#{action}") do |argument|
              send("#{type}_#{action}_callbacks") << argument
            end
          end
        end

        def inherited(subclass)
          # Initializes chains for all types of callbacks
          [:validation, :save, :create, :update, :destroy].each do |action|
            [:before, :after].each do |type|
              chain_name = "#{type}_#{action}_callbacks"
              class_attribute chain_name
              send("#{chain_name}=", [])
            end
          end

          super
        end
      end

      # Processes callbacks with specified type
      # @param [Symbol, String] type
      def process_callbacks(type)
        if respond_to?("#{type}_callbacks")
          send("#{type}_callbacks").each do |callback_name|
            send(callback_name)
          end
        end
      end
    end
  end
end