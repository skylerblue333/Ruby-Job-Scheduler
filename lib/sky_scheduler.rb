# frozen_string_literal: true

require "time"

module SkyScheduler
  MAX_JOBS = 1_000
  MAX_ID_BYTES = 128
  MAX_INTERVAL_SECONDS = 31_536_000

  class ValidationError < StandardError; end

  Job = Struct.new(:id, :interval_seconds, :next_run_at, keyword_init: true) do
    def due?(now)
      now >= next_run_at
    end

    def to_h
      {
        id: id,
        interval_seconds: interval_seconds,
        next_run_at: next_run_at.utc.iso8601
      }
    end
  end

  class Registry
    def initialize(max_jobs: MAX_JOBS)
      raise ValidationError, "max_jobs must be between 1 and #{MAX_JOBS}" unless max_jobs.is_a?(Integer) && max_jobs.between?(1, MAX_JOBS)

      @max_jobs = max_jobs
      @jobs = {}
    end

    def register(id:, interval_seconds:, start_at: Time.now.utc)
      validate_id!(id)
      validate_interval!(interval_seconds)
      raise ValidationError, "start_at must be a Time" unless start_at.is_a?(Time)
      raise ValidationError, "job capacity reached" if !@jobs.key?(id) && @jobs.size >= @max_jobs

      job = Job.new(id: id, interval_seconds: interval_seconds, next_run_at: start_at.utc)
      @jobs[id] = job
      job
    end

    def fetch(id)
      @jobs[id]
    end

    def remove(id)
      !@jobs.delete(id).nil?
    end

    def due(now: Time.now.utc)
      raise ValidationError, "now must be a Time" unless now.is_a?(Time)

      @jobs.values.select { |job| job.due?(now) }.sort_by(&:id)
    end

    def advance(id:, from: Time.now.utc)
      raise ValidationError, "from must be a Time" unless from.is_a?(Time)
      job = @jobs.fetch(id) { raise ValidationError, "unknown job" }

      next_run = job.next_run_at
      next_run += job.interval_seconds while next_run <= from
      job.next_run_at = next_run
      job
    end

    def size
      @jobs.size
    end

    def snapshot
      @jobs.values.sort_by(&:id).map(&:to_h)
    end

    private

    def validate_id!(id)
      unless id.is_a?(String) && !id.empty? && id.bytesize <= MAX_ID_BYTES && id.match?(/\A[a-zA-Z0-9._:-]+\z/)
        raise ValidationError, "id must be 1-#{MAX_ID_BYTES} bytes using letters, digits, dot, underscore, colon, or hyphen"
      end
    end

    def validate_interval!(value)
      unless value.is_a?(Integer) && value.between?(1, MAX_INTERVAL_SECONDS)
        raise ValidationError, "interval_seconds must be between 1 and #{MAX_INTERVAL_SECONDS}"
      end
    end
  end
end
