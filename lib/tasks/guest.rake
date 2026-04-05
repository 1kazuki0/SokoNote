namespace :guest do
  desc "ゲストユーザーのデータをリセット（24時）"
  task task_delete: :environment do
    guest = User.find_by(email: "guest@example.com")
    if guest
      guest.purchases.destroy_all
      puts "ゲストデータをリセットしました。"
    else
      puts "ゲストユーザーが見つかりません。"
    end
  end
end
