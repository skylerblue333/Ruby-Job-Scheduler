# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/sky_schedule"

class SkyScheduleTest < Minitest::Test
  def test_register_and_next_run
    scheduler = SkySchedule::Scheduler.new(capacity: 2)
    result = scheduler.register(id: "nightly.backup", interval_seconds: 60, start_at: "2026-01-01T00:00:00Z")

    assert_equal false, result[:command_execution]
    assert_equal "2026-01-01T00:02:00Z", scheduler.next_run(id: "nightly.backup", after: "2026-01-01T00:01:30Z")
  end

  def test_rejects_invalid_id_and_interval
    scheduler = SkySchedule::Scheduler.new
    assert_raises(ArgumentError) { scheduler.register(id: "bad id", interval_seconds: 60, start_at: "2026-01-01T00:00:00Z") }
    assert_raises(ArgumentError) { scheduler.register(id: "ok", interval_seconds: 0, start_at: "2026-01-01T00:00:00Z") }
  end

  def test_capacity_is_bounded
    scheduler = SkySchedule::Scheduler.new(capacity: 1)
    scheduler.register(id: "one", interval_seconds: 60, start_at: "2026-01-01T00:00:00Z")
    assert_raises(ArgumentError) { scheduler.register(id: "two", interval_seconds: 60, start_at: "2026-01-01T00:00:00Z") }
  end
end
