require 'spec_helper'

RSpec.describe Changed::Audit, type: :model do
  let(:changer) { build(:user) }

  around do |example|
    Changed.config(changer: changer) do
      example.run
    end
  end

  it do
    should belong_to :changer
    should belong_to :audited

    should_not allow_value('other').for(:event)

    Changed::Audit::EVENTS.each do |event|
      should allow_value(event).for(:event)
    end
  end

  describe '#track' do
    it 'tracks attribute for changes each event during the lifecycle of a typical object' do
      widget = build(:widget, quantity: 2)

      expect { widget.save! }.to change { Changed::Audit.creates.count }
      expect { widget.update!(quantity: 3) }.to change { Changed::Audit.updates.count }
      expect { widget.update!(quantity: 4) }.to change { Changed::Audit.updates.count }
      expect { widget.destroy! }.to change { Changed::Audit.destroys.count }
    end

    it 'does not track anything if non audited attributes are changed' do
      widget = create(:widget)

      expect { widget.update!(color: 'orange') }.to_not change { Changed::Audit.count }
    end

    it 'properly tracks changes for strings' do
      widget = create(:widget, name: 'Widget #123')
      audit = widget.audit
      widget.update!(name: 'Widget #321')

      field, = audit.fields
      expect(field).to be_present
      expect(field.name).to eql('name')
      expect(field.was).to eql('Widget #123')
      expect(field.now).to eql('Widget #321')
    end

    it 'properly tracks changes for timestamps' do
      widget = create(:widget, available: Time.parse('2018-12-31 7:00 AM'))
      audit = widget.audit
      widget.update!(available: Time.parse('2018-12-31 9:00 AM'))

      field, = audit.fields
      expect(field).to be_present
      expect(field.name).to eql('available')
      expect(Time.parse(field.was)).to eql(Time.parse('2018-12-31 7:00 AM'))
      expect(Time.parse(field.now)).to eql(Time.parse('2018-12-31 9:00 AM'))
    end

    it 'properly tracks changes for booleans' do
      widget = create(:widget, restricted: false)
      audit = widget.audit
      widget.update!(restricted: true)

      field, = audit.fields
      expect(field).to be_present
      expect(field.name).to eql('restricted')
      expect(field.was).to eql(false)
      expect(field.now).to eql(true)
    end

    it 'properly tracks changes for integers' do
      widget = create(:widget, quantity: 2)
      audit = widget.audit
      widget.update!(quantity: 4)

      field, = audit.fields
      expect(field).to be_present
      expect(field.name).to eql('quantity')
      expect(field.was).to eql(2)
      expect(field.now).to eql(4)
    end

    it 'properly tracks changes for decimals' do
      widget = create(:widget, price: 59.99)
      audit = widget.audit
      widget.update!(price: 39.99)

      field, = audit.fields
      expect(field).to be_present
      expect(field.name).to eql('price')
      expect(field.was).to eql('59.99')
      expect(field.now).to eql('39.99')
    end

    it 'properly tracks changes for belongs to associations' do
      old_vendor = create(:vendor)
      new_vendor = create(:vendor)
      widget = create(:widget, vendor: old_vendor)
      audit = widget.audit

      expect {
        widget.update!(vendor: new_vendor)
      }.to change { Changed::Audit.count }
        .and change { audit.associations.where(associated: new_vendor, name: 'vendor').add.count }
        .and change { audit.associations.where(associated: old_vendor, name: 'vendor').remove.count }
    end

    it 'does not generate an audit if a belongs to association is not changed' do
      vendor = create(:vendor)
      widget = create(:widget, vendor: vendor)

      expect {
        widget.update!(vendor: vendor)
      }.to_not change { Changed::Audit.count }
    end

    it 'properly tracks changes for has and belongs to many associations using push / delete flow' do
      old_part = create(:part)
      new_part = create(:part)
      widget = create(:widget, parts: [old_part])
      audit = widget.audit

      expect {
        widget.parts.push(new_part)
        widget.parts.delete(old_part)
        widget.save!
      }.to change { Changed::Audit.count }
        .and change { audit.associations.where(associated: new_part, name: 'parts').add.count }
        .and change { audit.associations.where(associated: old_part, name: 'parts').remove.count }
    end

    it 'properly tracks changes for has and belongs to many associations using the array accessor flow' do
      old_part = create(:part)
      new_part = create(:part)
      widget = create(:widget, parts: [old_part])
      audit = widget.audit

      expect {
        widget.parts = [new_part]
        widget.save!
      }.to change { Changed::Audit.count }
        .and change { audit.associations.where(associated: new_part, name: 'parts').add.count }
        .and change { audit.associations.where(associated: old_part, name: 'parts').remove.count }
    end

    it 'properly tracks changes for has and belongs to many associations using the attributes flow' do
      old_part = create(:part)
      new_part = create(:part)
      widget = create(:widget, parts: [old_part])
      audit = widget.audit

      expect {
        widget.attributes = { part_ids: [new_part.id] }
        widget.save!
      }.to change { Changed::Audit.count }
        .and change { audit.associations.where(associated: new_part, name: 'parts').add.count }
        .and change { audit.associations.where(associated: old_part, name: 'parts').remove.count }
    end

    it 'does not generate an audit if a has and belongs to many association is not changed' do
      part = create(:part)
      widget = create(:widget, parts: [part])

      expect {
        widget.parts = [part]
        widget.save!
      }.to_not change { Changed::Audit.count }
    end
  end

  describe '#track_attribute_change' do
    it 'does nothing if the value remains unchanged' do
      audit = build(:audit, changeset: {})

      value = 'value'
      change = -> { value = 'value' }

      audit.track_attribute_change(:field, change) { value }
      expect(audit.changeset['field']).to be_nil
    end

    it 'takes a block for the action and value to calculate a changeset' do
      audit = build(:audit, changeset: {})

      value = 'old_value'
      change = -> { value = 'new_value' }

      audit.track_attribute_change(:field, change) { value }
      expect(audit.changeset['field']).to eql(%w[old_value new_value])
    end
  end

  describe '#track_association_change' do
    it 'does nothing if the value remains unchanged' do
      audit = build(:audit)
      part = build(:part)

      parts = [part]
      change = -> { parts = [part] }

      audit.track_association_change(:parts, change) { parts }
      expect(audit.associations).to be_blank
    end

    it 'calculates the delta when adding / removing associations' do
      audit = build(:audit)

      old_part = build(:part)
      new_part = build(:part)

      parts = [old_part]
      change = -> { parts = [new_part] }

      audit.track_association_change(:regions, change) { parts }

      old_part_association = audit.associations.find { |association| association.associated.eql?(old_part) }
      new_part_association = audit.associations.find { |association| association.associated.eql?(new_part) }
      expect(old_part_association.kind).to eq('remove')
      expect(new_part_association.kind).to eq('add')
    end
  end

  describe '#fields' do
    it 'supports was and now attributes' do
      part = create(:part, name: 'Gear')
      audit = part.audit
      part.update!(name: 'Bolt')

      field, = audit.fields
      expect(field.name).to eql('name')
      expect(field.was).to eql('Gear')
      expect(field.now).to eql('Bolt')
    end

    it 'supports fields that are transformed' do
      part = create(:part, sku: '#ABCD')
      audit = part.audit
      part.update!(sku: '#DCBA')

      field, = audit.fields
      expect(field.name).to eql('stock keeping unit')
      expect(field.was).to eql('#ABCD')
      expect(field.now).to eql('#DCBA')
    end
  end

  describe '#relationships' do
    it 'supports association attributes' do
      old_vendor = create(:vendor)
      new_vendor = create(:vendor)
      widget = create(:widget, vendor: old_vendor)
      audit = widget.audit
      widget.update!(vendor: new_vendor)

      relationship, = audit.relationships
      expect(relationship.name).to eql('vendor')
    end
  end

  describe '#changed?' do
    let(:changer) { build(:user) }
    let(:audited) { build(:part) }
    let(:audit) { build(:audit, changer: changer, audited: audited, changeset: { name: %w[Gear Bolt] }) }

    it 'is truthy if an attribute changed' do
      expect(audit.changed?('name')).to be_truthy
    end

    it 'is falsey if an attribute is unchanged' do
      expect(audit.changed?('sku')).to be_falsey
    end
  end
end
