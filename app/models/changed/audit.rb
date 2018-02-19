module Changed
  class Audit < ApplicationRecord
    module Event
      CREATE = 'create'.freeze
      UPDATE = 'update'.freeze
      DESTROY = 'destroy'.freeze
    end

    EVENTS = [
      Event::CREATE,
      Event::UPDATE,
      Event::DESTROY,
    ].freeze

    belongs_to :changer, polymorphic: true, required: false
    belongs_to :audited, polymorphic: true
    has_many :associations, dependent: :destroy, class_name: 'Changed::Association'

    scope :optimized, -> { preload(:changer, :audited, associations: :associated) }
    scope :ordered, -> { order(id: :desc) }
    scope :creates, -> { where(event: Event::CREATE) }
    scope :updates, -> { where(event: Event::UPDATE) }
    scope :destroys, -> { where(event: Event::DESTROY) }

    validates :event, inclusion: { in: EVENTS }
    validates :audited, presence: true, unless: ->(audit) { audit.event.eql?(Event::DESTROY) }

    scope :for, ->(audited) { where(audited: audited).ordered }

    after_initialize -> { self.timestamp ||= (Changed.timestamp || Time.now) }

    def fields
      changeset.map do |name, value|
        was, now = value
        Field.new(was, now, transform(name))
      end
    end

    def relationships
      memo = {}
      associations.each do |association|
        memo[association.name] ||= Set.new
        memo[association.name] << association
      end
      memo.map do |name, associations|
        Relationship.new(associations, transform(name))
      end
    end

    def track(event, fields)
      self.changer = Changed.changer

      fields.each do |attribute|
        attribute = String(attribute)
        if audited.saved_change_to_attribute?(attribute)
          changeset[attribute] = audited.saved_change_to_attribute(attribute)
        end
      end

      self.event = event
    end

    def anything?
      changeset.any? || associations.any?
    end

    def changed_field?(key)
      fields.map(&:name).include?(key)
    end

    # The 'change' provided needs to be a block, lambda, or proc that executes
    # the changes. The other provided block is yielded pre and post the change.
    def track_attribute_change(attribute, change)
      attribute_was = yield
      change.call
      attribute_now = yield

      return if attribute_was == attribute_now

      changeset[String(attribute)] = [
        attribute_was,
        attribute_now,
      ]
    end

    def track_association_change(name, change)
      association_was = yield
      change.call
      association_now = yield
      return if association_was == association_now

      (association_was - association_now).each do |associated|
        associations.build(name: name, associated: associated, kind: :remove)
      end
      (association_now - association_was).each do |associated|
        associations.build(name: name, associated: associated, kind: :add)
      end
    end

  private

    def transform(name)
      (transformations[name] if transformations) || name
    end

    def transformations
      @transformations = audited.class.auditable[:transformations] unless defined?(@transformations)
      @transformations
    end

  end
end
