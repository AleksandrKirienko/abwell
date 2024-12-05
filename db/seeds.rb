# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# db/seeds.rb

# Очищаем существующие данные
puts 'Cleaning database...'
BuffTask.destroy_all
ApostolProfile.destroy_all
GameAccount.destroy_all

# Создаем game accounts
puts 'Creating game accounts...'
game_accounts = 3.times.map do |i|
  GameAccount.create!(
    vk_id: rand(100000..999999),
    buffs_received: rand(0..50)
  )
end

# Создаем apostol profiles
puts 'Creating apostol profiles...'
apostol_profiles = game_accounts.map do |game_account|
  ApostolProfile.create!(
    game_account: game_account,
    voice_count: rand(0..100),
    buffs_given: rand(0..30),
    chat_id: rand(1000..9999),
    races: [rand(1..5), rand(1..5)].uniq,
    last_buff_given_at: rand(1..10).days.ago
  )
end

# Создаем buff tasks
puts 'Creating buff tasks...'
10.times do
  game_account = game_accounts.sample
  apostol_profile = apostol_profiles.sample

  BuffTask.create!(
    game_account: game_account,
    apostol_profile: apostol_profile,
    buff_type: rand(0..3) # предполагая, что у нас есть 4 типа баффов (0-3)
  )
end
