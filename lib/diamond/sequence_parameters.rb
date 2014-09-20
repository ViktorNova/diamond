module Diamond

  # User-controller parameters that are used to formulate the note event sequence
  class SequenceParameters

    RANGE = {
      :gate => 1..500,
      :interval => -48..48,
      :pattern_offset => -16..16,
      :range => 0..10,
      :rate => 0..128,
      :transpose => -72..72
    }

    attr_reader :gate,
      :interval,
      :pattern,
      :pattern_offset,
      :range,
      :rate,
      :resolution

    # @param [Sequence] sequence
    # @param [Fixnum] resolution
    # @param [Hash] options
    # @option options [Fixnum] :gate Duration of the arpeggiated notes. The value is a percentage based on the rate.  If the rate is 4, then a gate of 100 is equal to a quarter note. (default: 75). must be 1..500
    # @option options [Fixnum] :interval Increment (pattern) over (interval) scale degrees (range) times.  May be positive or negative. (default: 12)
    # @option options [Fixnum] :pattern_offset Begin on the nth note of the sequence (but not omit any notes). (default: 0)
    # @option options [String, Pattern] :pattern Computes the contour of the arpeggiated melody.  Can be the name of a pattern or a pattern object.
    # @option options [Fixnum] :range Increment the (pattern) over (interval) scale degrees (range) times. Must be positive (abs will be used). (default: 3)
    # @option options [Fixnum] :rate How fast the arpeggios will be played. Must be positive (abs will be used). (default: 8, eighth note.) must be 0..resolution
    # @param [Proc] callback
    def initialize(sequence, resolution, options = {}, &callback)
      @transpose = 0
      @resolution = resolution
      @callback = callback
      apply_options(options)
      sequence.send(:use_parameters, self)
    end

    # Set the gate property
    # @param [Fixnum] num
    # @return [Fixnum]
    def gate=(num)
      @gate = constrain(num, :range => RANGE[:gate])
      mark_changed
      @gate
    end

    # Set the interval property
    # @param [Fixnum] num
    # @param [Fixnum]
    def interval=(num)
      @interval = num
      mark_changed
      @interval
    end

    # Set the pattern offset property
    # @param [Fixnum] num
    # @return [Fixnum]
    def pattern_offset=(num)
      @pattern_offset = num
      mark_changed
      @pattern_offset
    end

    # Set the range property
    # @param [Fixnum] range
    # @return [Fixnum]
    def range=(num)
      @range = constrain(num, :range => RANGE[:range])
      mark_changed
      @range
    end

    # Set the rate property
    # @param [Fixnum] num
    # @return [Fixnum]
    def rate=(num)
      @rate = constrain(num, :range => RANGE[:rate].begin..@resolution)
      mark_changed
      @rate
    end

    # Set the pattern property
    # @param [Pattern] pattern
    # @return [Pattern]
    def pattern=(pattern)
      @pattern = pattern
      mark_changed
      @pattern
    end

    # Transpose everything by the given number of scale degrees. Can be used as a getter
    # @param [Fixnum, nil] num
    # @return [Fixnum, nil]
    def transpose(num = nil)
      @transpose = num unless num.nil?
      mark_changed
      @transpose      
    end
    alias_method :transpose=, :transpose

    # The computed pattern given the sequence options
    # @return [Array<Fixnum>]
    def computed_pattern
      @pattern.compute(@range, @interval)
    end

    # The note duration given the sequence options
    # @return [Numeric]
    def duration
      @resolution / @rate
    end

    private

    # Mark that there's been a change in the sequence
    def mark_changed
      @callback.call
    end

    # @param [Hash] options
    # @return [ArpeggiatorSequence::Parameters]
    def apply_options(options)
      @interval = constrain((options[:interval] || 12), :range => RANGE[:interval])
      @range = constrain((options[:range] || 3), :range => RANGE[:range])
      @pattern_offset = constrain((options[:pattern_offset] || 0),:range => RANGE[:pattern_offset])
      @rate = constrain((options[:rate] || 8), :range => 0..@resolution)
      @gate = constrain((options[:gate] || 75), :range => RANGE[:gate])
      @pattern = get_pattern(options[:pattern])
      self
    end

    # Derive a pattern from the options or using the default
    # @param [Pattern, String, nil] option
    # @return [Pattern, nil]
    def get_pattern(option)
      @pattern = case option
                 when Pattern then option
                 when String then Pattern.find(option)
                 end
      @pattern ||= Pattern.first
    end

    # Constrain the given value based on the sequence options
    # @param [Numeric] value
    # @param [Hash] options
    # @option options [Numeric] :min
    # @option options [Numeric] :max
    # @option options [Range] :range
    # @return [Numeric]
    def constrain(value, options = {})
      min = options[:range].nil? ? options[:min] : options[:range].begin
      max = options[:range].nil? ? options[:max] : options[:range].end
      new_value = value
      new_value = min.nil? ? new_value : [new_value, min].max
      new_value = max.nil? ? new_value : [new_value, max].min
      new_value
    end

  end
end
