FactoryBot.define do
  factory :audit, class: 'Changed::Audit' do
    association :changer, factory: :user, strategy: :build
    association :audited, factory: :user, strategy: :build
    changeset do
      JSON.generate(name: %w[John Paul])
    end
  end
end
