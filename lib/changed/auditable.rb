require 'active_support/concern'

module Changed
  module Auditable
    extend ActiveSupport::Concern

    # ==== Overview
    #
    # A helper that caches an audit between operations. Once an audit is persisted this method handles the generation
    # of a new audit, thus ensuring that each transaction is audited separately.
    def audit
      @audit = Audit.new(audited: self) if @audit.nil? || @audit.persisted?
      @audit
    end

    included do
      has_many :audits, -> { ordered }, as: :audited, class_name: 'Changed::Audit'

      # ==== Overview
      #
      # A helper for setting up options.
      #
      def self.auditable
        @auditable ||= {}
      end

      # ==== Overview
      #
      # A concern for setting up auditable for a model. An audited model can track the changes to attributes
      # (ints, bools, strings, dates, times) or associations (`has_many`, `belongs_to`, `has_and_belongs_to_many`).
      #
      # The `audit` call needs to be placed after all `has_many`, `belongs_to`, `has_and_belongs_to_many` declarations
      # in order for the association reflection to work. Multiple inclusions of `audit` are not supported.
      #
      # ==== Options
      #
      # * +:keys:+ - An array of symbols for the attributes or associations that are tracked with each audit.
      # * +:transformations:+ - A hash of of attribute name mappings (i.e. 'number' to '#' or 'user' to 'rep').
      #
      # ==== Usage
      #
      #     audit(:number, :scheduled, :region, :address, :items, transformations: { number: "#", user: "rep" })
      #
      def self.audited(*keys, transformations: nil)
        auditable[:transformations] = ActiveSupport::HashWithIndifferentAccess.new(transformations) if transformations
        Builder.build(self, *keys)
      end
    end

  end
end
