# frozen_string_literal: true

require "minitest/autorun"
require "time"
require_relative "../lib/sky_scheduler"

class SkySchedulerTest < Minitest::Test
  def setup
    @registry = SkyScheduler::Registry.new(max_jobs: 2)
    @t0 = Time.parse("2026-08-24T00:00:00Z")
  end

  def test_register_due_and_advance
    job = @registry.register(id: "billing.daily", interval_seconds: 60, start_at: @t0)
    assert job.due?(@t0)
    assert_equal ["billing.daily"], @registry.due(now: @t0).map(&:id)

    advanced = @registry.advance(id: "billing.daily", from: @t0)
    assert_equal @t0 + 60, advanced.next_run_at
    refute advanced.due?(@t0)
  end

  def test_advance_skips_missed_intervals
    @registry.register(id: "sync", interval_seconds: 10, start_at: @t0)
    advanced = @registry.advance(id: "sync", from: @t0 + 35)
    assert_equal @t0 + 40, advanced.next_run_at
  end

  def test_capacity_and_validation
    @registry.register(id: "a", interval_seconds: 1, start_at: @t0)
    @registry.register(id: "b", interval_seconds: 2, start_at: @t0)

    assert_raises(SkyScheduler::ValidationError) do
      @registry.register(id: "c", interval_seconds: 3, start_at: @t0)
    end
    assert_raises(SkyScheduler::ValidationError) do
      @registry.register(id: "bad id", interval_seconds: 3, start_at: @t0)
    end
    assert_raises(SkyScheduler::ValidationError) do
      SkyScheduler::Registry.new(max_jobs: 0)
    end
  end

  def test_snapshot_is_stable
    @registry.register(id: "z", interval_seconds: 5, start_at: @t0)
    @registry.register(id: "a", interval_seconds: 5, start_at: @t0)
    assert_equal ["a", "z"], @registry.snapshot.map { |row| row[:id] }
  end
end
