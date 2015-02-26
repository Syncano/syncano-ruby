module Syncano
  module Model
    # ScopeBuilder class allows for creating and chaining more complex queries
    class ScopeBuilder
      # Constructor for ScopeBuilder
      # @param [Class] model
      def initialize(model)
        raise 'Model should be a class extending module Syncano::Model::Base' unless model <= Syncano::Model::Base

        self.model = model
        self.parameters = {}
      end
      #
      # Returns collection of objects
      # @return [Array]
      def all
        model.syncano_class.objects.all.collect do |data_object|
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

      # # Returns first object or collection of first x objects
      # # @param [Integer] amount
      # # @return [Object, Array]
      # def first(amount = nil)
      #   objects = all.first(amount || 1)
      #   amount.nil? ? objects.first : objects
      # end
      #
      # # Returns last object or last x objects
      # # @param [Integer] amount
      # # @return [Object, Array]
      # def last(amount)
      #   objects = all.last(amount || 1)
      #   amount.nil? ? objects.first : objects
      # end
      #
      # # Adds to the current scope builder condition to the scope builder
      # # @param [String] condition
      # # @param [Array] params
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def where(condition, *params)
      #   raise 'Invalid params count in where clause!' unless condition.count('?') == params.count
      #
      #   params.each do |param|
      #     condition.sub!('?', param.to_s)
      #   end
      #
      #   conditions = condition.gsub(/\s+/, ' ').split(/and/i)
      #
      #   conditions.each do |condition|
      #     attribute, operator, value = condition.split(' ')
      #
      #     raise 'Invalid attribute in where clause!' unless model.attributes.keys.include?(attribute)
      #     raise 'Invalid operator in where clause!' unless self.class.where_mapping.keys.include?(operator)
      #     raise 'Parameter in where clause is not an integer!' if !(value =~ /\A[-+]?[0-9]+\z/)
      #
      #     method_name = "#{model.filterable_attributes[attribute]}__#{self.class.where_mapping[operator]}"
      #     parameters[method_name] = value
      #   end
      #
      #   self
      # end
      #
      # # Adds to the current scope builder condition for filtering by parent_id
      # # @param [Integer] parent_id
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def by_parent_id(parent_id)
      #   parameters[:parent_ids] = parent_id
      #   self
      # end
      #
      # # Adds to the current scope builder order clause
      # # @param [String] order
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def order(order)
      #   attribute, order_type = order.gsub(/\s+/, ' ').split(' ')
      #   raise 'Invalid attribute in order clause' unless (model.attributes.keys + ['id', 'created_at']).include?(attribute)
      #
      #   attribute = model.map_to_syncano_attribute(attribute)
      #   order_type = order_type.to_s.downcase == 'desc' ? 'DESC' : 'ASC'
      #
      #   self.parameters.merge!({ order_by: attribute, order: order_type })
      #
      #   self
      # end
      #
      # # Adds to the current scope builder condition for filtering by ids newer than provided
      # # @param [Integer, String] id - id or datetime
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def since(id)
      #   if !(id =~ /\A[-+]?[0-9]+\z/)
      #     self.parameters[:since] = id
      #   else
      #     self.parameters[:since_time] = id.to_time
      #   end
      #   self
      # end
      #
      # # Adds to the current scope builder condition for filtering by ids older than provided
      # # @param [Integer] id
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def before(id)
      #   self.parameters[:max_id] = id
      #   self
      # end
      #
      # # Adds to the current scope builder limit clause
      # # @param [Integer] amount
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def limit(amount)
      #   self.parameters[:limit] = amount
      #   self
      # end
      #
      private

      attr_accessor :parameters, :model, :scopes

      # Returns Syncano::Resource class for current model
      # @return [Syncano::Resources::Folder]
      def syncano_class
        model.syncano_class
      end
      #
      # # Returns scopes for current model
      # # @return [HashWithIndifferentAccess]
      # def scopes
      #   model.scopes
      # end
      #
      # # Returns mapping for operators
      # # @return [Hash]
      # def self.where_mapping
      #   { '=' => 'eq', '!=' => 'neq', '<>' => 'neq', '>=' => 'gte', '>' => 'gt', '<=' => 'lte', '<' => 'lt' }
      # end
      #
      # # Applies scope to the current scope builder
      # # @param [Symbol] name
      # # @param [Array] args
      # # @return [Syncano::ActiveRecord::ScopeBuilder]
      # def execute_scope(name, *args)
      #   procedure = scopes[name]
      #   instance_exec(*args, &procedure)
      #   self
      # end
      #
      # # Overwritten method_missing for handling calling defined scopes
      # # @param [String] name
      # # @param [Array] args
      # def method_missing(name, *args)
      #   if scopes[name].nil?
      #     super
      #   else
      #     execute_scope(name, *args)
      #   end
      # end
    end
  end
end