# frozen_string_literal: true

require "time"

module SkySchedule
  MAX_JOBS = 1_000
  MAX_ID = 96
  MAX_INTERVAL_SECONDS = 31_536_000

  Job = Struct.new(:id, :interval_seconds, :next_run_at, keyword_init: true)

  class Scheduler
    def initialize(capacity: MAX_JOBS)
      raise ArgumentError, "invalid capacity" unless capacity.between?(1, MAX_JOBS)

      @capacity = capacity
      @jobs = {}
    end

    def register(id:, interval_seconds:, start_at:)
      validate_id!(id)
      validate_interval!(interval_seconds)
      start = parse_time(start_at)
      raise ArgumentError, "capacity exceeded" if !@jobs.key?(id) && @jobs.length >= @capacity

      job = Job.new(id: id, interval_seconds: interval_seconds, next_run_at: start.utc)
      @jobs[id] = job
      snapshot(job)
    end

    def next_run(id:, after:)
      job = @jobs.fetch(id) { raise KeyError, "job not found" }
      cursor = parse_time(after).utc
      next_at = job.next_run_at
      if cursor >= next_at
        elapsed = cursor.to_i - next_at.to_i
        steps = (elapsed / job.interval_seconds) + 1
        next_at += steps * job.interval_seconds
      end
      next_at.iso8601
    end

    def list
      @jobs.values.sort_by(&:id).map { |job| snapshot(job) }
    end

    private

    def validate_id!(id)
      valid = id.is_a?(String) && id.match?(/\A[a-zA-Z0-9._-]+\z/) && id.length.between?(1, MAX_ID)
      raise ArgumentError, "invalid id" unless valid
    end

    def validate_interval!(value)
      raise ArgumentError, "invalid interval" unless value.is_a?(Integer) && value.between?(1, MAX_INTERVAL_SECONDS)
    end

    def parse_time(value)
      value.is_a?(Time) ? value : Time.iso8601(String(value))
    rescue ArgumentError
      raise ArgumentError, "invalid timestamp"
    end

    def snapshot(job)
      {
        id: job.id,
        interval_seconds: job.interval_seconds,
        first_run_at: job.next_run_at.iso8601,
        command_execution: false
      }
    end
  end
end
