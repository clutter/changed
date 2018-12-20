module Changed
  class Builder
    class ArgumentError < ::ArgumentError
    end

    ARGUMENT_ERROR_EMPTY_KEYS_MESSAGE = 'audited requires specifying a splat of keys'.freeze

    def self.build(*args)
      new(*args).build
    end

    def initialize(klass, *keys)
      raise ArgumentError, ARGUMENT_ERROR_EMPTY_KEYS_MESSAGE if keys.empty?

      @klass = klass
      @keys = keys
    end

    def build
      define_callbacks_for_associations
      define_after_create_callback
      define_after_update_callback
    end

  private

    def define_callbacks_for_associations
      @keys.each do |key|
        association = @klass.reflect_on_association(key)
        case association
        when ActiveRecord::Reflection::HasManyReflection,
          ActiveRecord::Reflection::HasAndBelongsToManyReflection,
          ActiveRecord::Reflection::ThroughReflection
          define_callbacks_for_has_many(association)
        when ActiveRecord::Reflection::BelongsToReflection
          define_callbacks_for_belongs_to(association)
        when ActiveRecord::Reflection::HasOneReflection
          define_callbacks_for_has_one(association)
        end
      end
    end

    def after_create_or_update_for_belongs_to_callback(key, foreign_key, foreign_type, class_name)
      proc do |resource|
        was_associated_id, now_associated_id = resource.saved_change_to_attribute(foreign_key)
        was_associated_type, now_associated_type = resource.saved_change_to_attribute(foreign_type)
        associated_type = resource[foreign_type] || class_name

        if was_associated_id
          resource.audit.associations.build(
            name: key,
            kind: :remove, associated_id: was_associated_id, associated_type: was_associated_type || associated_type
          )
        end

        if now_associated_id
          resource.audit.associations.build(
            name: key, kind: :add,
            associated_id: now_associated_id, associated_type: now_associated_type || associated_type
          )
        end
      end
    end

    def define_callbacks_for_belongs_to(association)
      callback = after_create_or_update_for_belongs_to_callback(association.name,
        association.foreign_key, association.foreign_type, association.class_name)

      @klass.after_update callback
      @klass.after_create callback
    end

    def before_add_for_has_many_callback(name)
      proc do |_method, resource, associated|
        resource.audit.associations.build(name: name, associated: associated, kind: :add)
      end
    end

    def before_remove_for_has_many_callback(name)
      proc do |_method, resource, associated|
        resource.audit.associations.build(name: name, associated: associated, kind: :remove)
      end
    end

    def define_callbacks_for_has_many(association)
      name = association.name
      @klass.send(:"before_add_for_#{association.name}") << before_add_for_has_many_callback(name)
      @klass.send(:"before_remove_for_#{association.name}") << before_remove_for_has_many_callback(name)
    end

    def define_callbacks_for_has_one(association)
      raise ArgumentError, "unsupported reflection '#{association.name}'"
    end

    def define_after_create_callback
      keys = @keys
      @klass.after_create do |resource|
        audit = resource.audit
        audit.track(Audit::Event::CREATE, keys)
        audit.save! if audit.anything?
      end
    end

    def define_after_update_callback
      keys = @keys
      @klass.after_update do |resource|
        audit = resource.audit
        audit.track(Audit::Event::UPDATE, keys)
        audit.save! if audit.anything?
      end
    end
  end
end
