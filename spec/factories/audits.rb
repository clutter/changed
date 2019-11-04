FactoryBot.define do
  factory :audit, class: 'Changed::Audit' do
    association(:changer, factory: :user)
    association(:audited, factory: :user)
    changeset { JSON.generate(name: %w[John Paul]) }
  end
end
