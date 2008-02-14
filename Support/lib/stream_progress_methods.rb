module StreamProgressMethods
  
  def each_line_from_stream(stream, &block)
    line = ""
    stream.each_byte do |char|
      char = [char].pack('c')
      line << char
      next unless char=="\n" || char=="\r"
      yield line
      line = ""
    end
  end

  def process_with_progress(stream, options = {}, &block)
    options[:start_regexp] ||= /([a-z]+) ([0-9]+) objects/i
    options[:progress_regexp] ||= /([0-9]+)% \(([0-9]+)\/([0-9]+)\) done/
    callbacks = options[:callbacks]
    state = nil
    each_line_from_stream(stream) do |line|
      case line
      when options[:start_regexp]
        state = $1
        callbacks[:start] && callbacks[:start].call(state, $2.to_i)
        percentage, index, count = 0, 0, $2.to_i
      when options[:progress_regexp]
        percentage, index, count = $1.to_i, $2.to_i, $3.to_i
      else
        yield line
      end

      if state
        callbacks[:progress] && callbacks[:progress].call(state, percentage, index, count)
        if percentage == 100
          callbacks[:end] && callbacks[:end].call(state, count)
          state = nil 
        end
      end
    end
  end

  def get_rev_range(input)
    revs = input.split("..").compact
    revs = ["#{revs[0]}^", revs[0]] if revs.length == 1
    revs
  end


end