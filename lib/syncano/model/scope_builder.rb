module Syncano
  module Model
    # ScopeBuilder class allows for creating and chaining more complex queries
    class ScopeBuilder
      # Constructor for ScopeBuilder
      # @param [Class] model
      def initialize(model)
        raise 'Model should be a class extending module Syncano::Model::Base' unless model <= Syncano::Model::Base

        self.model = model
        self.query = HashWithIndifferentAccess.new
      end

      # Returns collection of objects
      # @return [Array]
      def all
        model.syncano_class.objects.all(parameters).collect do |data_object|
          model.new(data_object)
        end
      end

      # Returns one object found by id
      # @param [Integer] id
      # @return [Object]
      def find(id)
        data_object = model.syncano_class.objects.find(id)
        data_object.present? ? model.new(data_object) : nil
      end

      # Returns first object or collection of first x objects
      # @param [Integer] amount
      # @return [Object, Array]
      def first(amount = nil)
        objects = all.first(amount || 1)
        amount.nil? ? objects.first : objects
      end

      # Returns last object or last x objects
      # @param [Integer] amount
      # @return [Object, Array]
      def last(amount)
        objects = all.last(amount || 1)
        amount.nil? ? objects.first : objects
      end

      # Adds to the current scope builder condition to the scope builder
      # @param [String] condition
      # @param [Array] params
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def where(conditions, *params)
        raise 'Invalid params count in where clause!' unless conditions.count('?') == params.count

        params = params.dup

        conditions.gsub(/\s+/, ' ').split(/and/i).each do |condition|
          if condition.ends_with?('?')
            value = params.shift
            condition.gsub!('?', '').strip!
          else
            value = true
          end

          attribute, operator = condition.split(' ', 2)
          operator.upcase!

          raise 'Invalid attribute in where clause!' unless model.attributes.keys.include?(attribute)
          raise 'Invalid operator in where clause!' unless self.class.where_mapping.keys.include?(operator)

          operator = self.class.where_mapping[operator]

          query[attribute] = HashWithIndifferentAccess.new if query[attribute].nil?
          query[attribute][operator] = value
        end

        self
      end

      # Adds to the current scope builder order clause
      # @param [String] order
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def order(order)
        if order.is_a?(Hash)
          attribute = order.keys.first
          order_type = order[attribute]
        else
          attribute, order_type = order.gsub(/\s+/, ' ').split(' ')
        end

        raise 'Invalid attribute in order clause' unless (model.attributes.keys).include?(attribute)

        self.order_clause = order_type.to_s.downcase == 'desc' ? "-#{attribute}" : attribute

        self
      end

      # # Adds to the current scope builder limit clause
      # # @param [Integer] amount
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def limit(amount)
      #   self.parameters[:limit] = amount
      #   self
      # end
      #
      private

      attr_accessor :order_clause, :query, :model, :scopes

      # Returns Syncano::Resource class for current model
      # @return [Syncano::Resources::Folder]
      def syncano_class
        model.syncano_class
      end

      # Returns scopes for current model
      # @return [HashWithIndifferentAccess]
      def scopes
        model.scopes
      end

      def parameters
        params = {}

        params[:order_by] = order_clause if order_clause.present?
        params[:query] = query.to_json if query.present?

        params
      end

      # Returns mapping for operators
      # @return [Hash]
      def self.where_mapping
        { '=' => '_eq', '!=' => '_neq', '<>' => '_neq', '>=' => '_gte', '>' => '_gt',
          '<=' => '_lte', '<' => '_lt', 'IS NOT NULL' => '_exists', 'IN' => '_in' }
      end

      # Applies scope to the current scope builder
      # @param [Symbol] name
      # @param [Array] args
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def execute_scope(name, *args)
        procedure = scopes[name]
        instance_exec(*args, &procedure)
        self
      end

      # Overwritten method_missing for handling calling defined scopes
      # @param [String] name
      # @param [Array] args
      def method_missing(name, *args)
        if scopes[name].nil?
          super
        else
          execute_scope(name, *args)
        end
      end
    end
  end
end