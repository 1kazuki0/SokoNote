FactoryBot.define do
  # --- 通常のメール登録ユーザー ---
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" } # Devise validatableのデフォルトは6文字以上
    password_confirmation { password }
    provider { nil }
    uid { nil }

    # --- LINEログインユーザー用のtrait ---
    trait :line_user do
      email { nil }
      password { nil }
      password_confirmation { nil }
      provider { "line" }
      sequence(:uid) { |n| "line_uid_#{n}" } # provider内で一意
    end
  end
end
