# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 10.times do
#   User.create(name: Faker::Name.first_name,
#               email: Faker::Internet.unique.email,
#               password: "password")
# end

# user_id:22 category_id:4を固定し代入
user = User.find(22)
category = Category.find(4)
# 10回繰り返し
10.times do
  Item.create(user: user,
              category: category,
              name: Faker::Food.unique.vegetables) # uniqueで今まで出したデータと被らないようにする。
end

# docker compose exec web rails db:seedで実行すると10件分のItemが生成される
