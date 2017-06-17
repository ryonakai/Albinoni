require 'digest/sha2'
class LilyBuffer
  @@buffer = []
  @@time = []
  @@hash_stack = ''
  @@relative = ''
  class <<self
    def setRelativeOctave(the_first_pitch, the_first_ix)
      # simple 'c' is
      # a,, is 21 -> b,, 22 -> c, 24 -> c 36
      oct = (the_first_pitch / 12.0).floor
      # oct = 2 -> c,--h,
      # oct = 3 -> c--h etc.
      oct -= 1 if the_first_ix <= 4 # lower than F
      if oct == 3
        @@relative = 'c'
      elsif oct < 3
        @@relative = 'c' + (',' * (3 - oct))
      else
        @@relative = 'c' + ('\'' * (oct - 3))
      end
    end
    def add(obj)
      obj[:id] = getCurrentSHA256
      if obj[:type] == :chord || obj[:type] == :rest
        @@time.push obj[:length_text]
      end
      @@buffer.push(obj)
    end
    def reset
      @@buffer = []
    end
    def getAll
      return @@buffer
    end
    def setAll(objs)
      @@buffer = objs
    end
    def getNewestNoteId
      (@@buffer.length - 1).downto(0){ |i|
        return i if @@buffer[i][:type] == :chord || @@buffer[i][:type] == :rest
      }
    end
    def addNoteStack(text_or_hash)
      id = getNewestNoteId
      if text_or_hash.instance_of?(Hash)
        text = text_or_hash[:text]
      else
        text = text_or_hash
      end
      @@buffer[id][:buffer] = (@@buffer[id][:buffer] || '') + text
    end
    def expandText
      text = ''
      text << "\\relative #{@@relative}{\n  "
      ds_text = "{\n  "

      full_measure_rest_continuing = 0
      last_full_measure_length = '**'

        realstackend = ''

      @@buffer.each do |b|
        if b[:type] == :timesig
            time = b[:time]
            ds_text << "% " + b[:text]
            ds_text << "\n  "
        end

        if b[:type] == :bar and b[:barType] == :normal
          text << "|\n  " unless full_measure_rest_continuing > 0
          ds_text << "|\n  " unless full_measure_rest_continuing > 0
          next
        end

        if b[:full_measure_rest_simple]
          if full_measure_rest_continuing == 0
            full_measure_rest_continuing = 1
            last_full_measure_length = b[:length_text]
            realstackend << b[:stack_real_end]
            next
          end
          if b[:length_text] == last_full_measure_length
            # continue counting full measure rest
            full_measure_rest_continuing += 1
            realstackend << b[:stack_real_end]
            next
          end
        end

        # continued full length rest ended.
        if full_measure_rest_continuing > 0
          text << 'R' + last_full_measure_length + (full_measure_rest_continuing == 1 ? '' : ('*' + full_measure_rest_continuing.to_s)) + realstackend + " |\n  "
          ds_text << 's' + last_full_measure_length + (full_measure_rest_continuing == 1 ? '' : ('*' + full_measure_rest_continuing.to_s)) + " |\n  "
          full_measure_rest_continuing = 0
          realstackend = ''
        end

        if b[:full_measure_rest_simple]
          full_measure_rest_continuing = 1
          last_full_measure_length = b[:length_text]
          realstackend << b[:stack_real_end]
        end

        if b[:type] == :rest || b[:type] == :chord
          if b[:note_text][0] == 'R'
            b[:articulation].gsub!('\fermata','^\fermataMarkup')
          end
          text << b[:note_text] + b[:dynamic] + b[:articulation] + b[:suffix_end] + (b[:buffer]||'') + b[:tie] + b[:stack_real_end] + b[:stack_end] + ' ' + b[:suffix_start]
          ds_text << 's' + b[:real_length_text] + " "
        elsif b[:type] == :tempo
          ds_text << '\tempo' + b[:markup][:text] + "\n  "
          #text << '\tempo' + b[:markup][:text]
          #text << "\n  "
        elsif b[:type] == :rehearsalmark || b[:type] == :bar
          ds_text << b[:text] + "\n  "
          #text << '\tempo' + b[:markup][:text]
          #text << "\n  "
        else
          text << b[:text]
          text << "\n  "
        end
      end
      text.rstrip!
      text << "\n}"
      ds_text.rstrip!
      ds_text << "\n}"
      return text, ds_text
    end
    def getAndUpdateCurrentSHA256(obj)
      text = @@hash_stack + obj.to_s
      hash = Digest::SHA256.hexdigest(text);
      @@hash_stack = hash
      return hash
    end
    def getCurrentSHA256()
      return @@hash_stack
    end
  end
end
