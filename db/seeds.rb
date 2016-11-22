# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(name: 'BOT',      icon: 'monochro.infinity@gmail.com', password: 'botbotbot'    )
User.create(name: 'tkg',      icon: '2', password: 'tkgtkgtkg'    )
User.create(name: 'AO',       icon: '3', password: 'aoaoaoao'    )
User.create(name: 'bun',      icon: '4', password: 'bunbunbun'    )
User.create(name: 'kmkt',     icon: '5', password: 'kmktkmkt'  )
User.create(name: 'kubo',     icon: '6', password: 'kubokubo'  )
User.create(name: 'takayama', icon: '7', password: 'takayama'  )
User.create(name: 'satop',    icon: '8', password: 'satopsatop')
User.create(name: 'guest',    icon: 'chatravel.guest@gmail.com', password: 'mashup').save!

r = Room.create(name: 'monochrome', enable: true, url: 'xxxxxxxxxxxx')
r.users << User.all

r.messages << Message.create(message: 'from bot',      user_id: 1)
r.messages << Message.create(message: 'from tkg',      user_id: 2)
r.messages << Message.create(message: 'from AO',       user_id: 3)
r.messages << Message.create(message: 'from bun',      user_id: 4)
r.messages << Message.create(message: 'from kmkt',     user_id: 5)
r.messages << Message.create(message: 'from kubo',     user_id: 6)
r.messages << Message.create(message: 'from takayama', user_id: 7)
r.messages << Message.create(message: 'from satop',    user_id: 8)

r.suggests << Suggest.create(url: "https://tabelog.com/tokyo/A1304/A130401/13187168/",
                             description: "★★★☆☆3.56 ■日本初！油そばにローストビーフ！？大人のグルメ系油そば「ローストビーフ油そばビースト」肉増しあり、トッピングによるカスタマイズありでマイ油そばをお楽しみ下さい。 ■予算(夜):￥1,000～￥1,999",
                             title: "ローストビーフ油そば ビースト - 西武新宿/油そば [食べログ]",
                             image: "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/43696/200x200_square_43696528.jpg",
                             enable: false,
                             user_id: 1)
r.suggests << Suggest.create(url: "https://tabelog.com/tokyo/A1301/A130103/13140809/",
                             description: "★★★☆☆3.59 ■俺のフレンチ銀座本店 ここが俺のフレンチの始まりの場所！！ ■予算(夜):￥4,000～￥4,999俺のフレンチ 銀座本店 (新橋/ビストロ)★★★☆☆3.59 ■俺のフレンチ銀座本店 ここが俺のフレンチの始まりの場所！！ ■予算(夜):￥4,000～￥4,999",
                             title: "俺のフレンチ 銀座本店 - 新橋/ビストロ [食べログ]",
                             image: "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/39448/200x200_square_39448099.jpg",
                             enable: false,
                             user_id:2)

r.suggests << Suggest.create(url: "https://tabelog.com/tokyo/A1304/A130401/13187168/",
                             description: "★★★☆☆3.56 ■日本初！油そばにローストビーフ！？大人のグルメ系油そば「ローストビーフ油そばビースト」肉増しあり、トッピングによるカスタマイズありでマイ油そばをお楽しみ下さい。 ■予算(夜):￥1,000～￥1,999",
                             title: "Aローストビーフ油そば ビースト - 西武新宿/油そば [食べログ]",
                             image: "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/43696/200x200_square_43696528.jpg",
                             enable: false,
                             user_id: 3)

r.suggests << Suggest.create(url: "https://tabelog.com/tokyo/A1304/A130401/13187168/",
                             description: "★★★☆☆3.56 ■日本初！油そばにローストビーフ！？大人のグルメ系油そば「ローストビーフ油そばビースト」肉増しあり、トッピングによるカスタマイズありでマイ油そばをお楽しみ下さい。 ■予算(夜):￥1,000～￥1,999",
                             title: "Bローストビーフ油そば ビースト - 西武新宿/油そば [食べログ]",
                             image: "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/43696/200x200_square_43696528.jpg",
                             enable: false,
                             user_id: 4)

r.suggests << Suggest.create(url: "https://tabelog.com/tokyo/A1304/A130401/13187168/",
                             description: "★★★☆☆3.56 ■日本初！油そばにローストビーフ！？大人のグルメ系油そば「ローストビーフ油そばビースト」肉増しあり、トッピングによるカスタマイズありでマイ油そばをお楽しみ下さい。 ■予算(夜):￥1,000～￥1,999",
                             title: "Cローストビーフ油そば ビースト - 西武新宿/油そば [食べログ]",
                             image: "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/43696/200x200_square_43696528.jpg",
                             enable: true,
                             user_id: 5)
r.suggests << Suggest.create(url: "https://tabelog.com/tokyo/A1304/A130401/13187168/",
                             description: "★★★☆☆3.56 ■日本初！油そばにローストビーフ！？大人のグルメ系油そば「ローストビーフ油そばビースト」肉増しあり、トッピングによるカスタマイズありでマイ油そばをお楽しみ下さい。 ■予算(夜):￥1,000～￥1,999",
                             title: "Dローストビーフ油そば ビースト - 西武新宿/油そば [食べログ]",
                             image: "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/43696/200x200_square_43696528.jpg",
                             enable: true,
                             user_id: 6)

o = 1
Suggest.all.each do |s|
  unless s.enable
    d = Decided.create(order:o)
    d.suggest = s
    r.decideds << d
    o = 1
  end
end
r.save
