# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.new(name: 'BOT',      icon: '1', password: 'botbot'    ).save!
User.new(name: 'tkg',      icon: '2', password: 'tkgtkg'    ).save!
User.new(name: 'AO',       icon: '3', password: 'aoaoao'    ).save!
User.new(name: 'bun',      icon: '4', password: 'bunbun'    ).save!
User.new(name: 'kmkt',     icon: '5', password: 'kmktkmkt'  ).save!
User.new(name: 'kubo',     icon: '6', password: 'kubokubo'  ).save!
User.new(name: 'takayama', icon: '7', password: 'takayama'  ).save!
User.new(name: 'satop',    icon: '8', password: 'satopsatop').save!

Room.new(name: 'monochrome', enable: true, url: 'xxxxxxxxxxxx').save!

RoomToUser.new(user_id: 1, room_id:1).save!
RoomToUser.new(user_id: 2, room_id:1).save!
RoomToUser.new(user_id: 3, room_id:1).save!
RoomToUser.new(user_id: 4, room_id:1).save!
RoomToUser.new(user_id: 5, room_id:1).save!
RoomToUser.new(user_id: 6, room_id:1).save!
RoomToUser.new(user_id: 7, room_id:1).save!
RoomToUser.new(user_id: 8, room_id:1).save!

Message.new(message: 'from bot',      room_id: 1, user_id: 1).save!
Message.new(message: 'from tkg',      room_id: 1, user_id: 2).save!
Message.new(message: 'from AO',       room_id: 1, user_id: 3).save!
Message.new(message: 'from bun',      room_id: 1, user_id: 4).save!
Message.new(message: 'from kmkt',     room_id: 1, user_id: 5).save!
Message.new(message: 'from kubo',     room_id: 1, user_id: 6).save!
Message.new(message: 'from takayama', room_id: 1, user_id: 7).save!
Message.new(message: 'from satop',    room_id: 1, user_id: 8).save!
