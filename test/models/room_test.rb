require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  # TODO テストの設計
  test "create room" do
    room = Room.new(name: 'hoge', enable: true)
    assert room.save!
  end

  test "create room name = 50" do
    room = Room.new(name: 'x' * 50, enable: true)
    assert room.save!
  end

  test "fail empty room name" do
    room = Room.new(name: '', enable: true)
    assert_raises { room.save! }
  end
end
