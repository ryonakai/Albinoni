class LilyNote
  @@last_note = nil
  @@current_octavation = 0  # \ottava の値
  @@octavation_diff = 0
  def initialize(h)
    # h -- hash
    # el -- REXML object
    if h['Note']
      @is_chord = h['Note'].length > 1
      @notes = h['Note']
    else
      @notes = []
    end
    @length_text = h['durationType'][0];
    if h['Tag']
      (h['Tag'] || []).each do |tg|
        tn = tg['realTagName']
        h[tn] = [] unless h[tn]
        h[tn].push tg['__content__']
      end
    end
    @tuplets = h['Tuplet'];
    @dots = h['dots'][0].to_i rescue 0 ;
    @articulations = h['Articulation'][0] rescue []

    @slur = h['Slur'][0]['type'] if h['Slur']
    @isRest = (h['realTagName'] == 'Rest')
  end

  def to_lily
    pitches = []
    tie = ''
    if @isRest
      note_text = 'r'
      the_type = :rest
    else
      is_first_in_code = true
      last_note_in_chord = nil
      for note in @notes
        #if note['tpc2']
        #  Context::setTransposition(note['tpc'][0].to_i - note['tpc2'][0].to_i)
        #end
        tpc = note['tpc'][0].to_i
        accidental = note['Accidental'] ? '!' : ''
        tie = '~' if note['Tie']
        pitches.push TPC::to_tone_name(tpc) + relative_octave(note, last_note_in_chord) + accidental # +  "(#{note['pitch']})"
        last_note_in_chord = note
        @@last_note = note if is_first_in_code
        is_first_in_code = false
      end
      note_text = pitches.join(' ')
      if @is_chord
        note_text = '<' + note_text + '>'
      end
      the_type = :chord
    end


    @full_measure_rest = false
    if @length_text == 'measure'
      note_text = 'R'
      @length_lily = Context::getFullMeasureLengthText()
      @full_measure_rest = true
    else
      @length_lily = Duration::to_lily(@length_text, @dots)
    end

    real_length_text = Context::compareLastLength(@length_lily)
    note_text << real_length_text
    Context::setLastLength(@length_lily)


    # Pending objects attached to notes
    dynamic = Pending::getDynamic
    articulation_text = ''
    # Articulations
    @articulations = [@articulations] unless @articulations.instance_of?(Array)
    for artc in @articulations
      articulation_text << Articulation::to_lily(artc['subtype'][0])
    end

    # Brackets
    suffix_start = ''
    suffix_end = ''

    if @slur == 'start'
      suffix_start << '('
    elsif @slur == 'stop'
      suffix_end << ')'
    end

    Context::checkTuplets(@tuplets)
    stk =  Context::getStack
    estk = Context::getEndingStack
    return {
      :type => the_type,
      :dynamic => dynamic,
      :articulation => articulation_text,
      :full_measure_rest_simple => @full_measure_rest && ((suffix_end + tie + stk + suffix_start + dynamic + articulation_text) == ""),
      :length_text => @length_lily,
      :real_length_text => real_length_text,
      :note_text => note_text,
      :suffix_end => suffix_end,
      :tie => tie,
      :stack_end => stk,
      :stack_real_end => estk,
      :suffix_start => suffix_start,
    }
  end

  def relative_octave(note, last_note_in_chord = nil)
    if (last_note_in_chord || @@last_note) == nil
      LilyBuffer::setRelativeOctave(note['pitch'][0].to_i, TPC::to_ix(note['tpc'][0].to_i))
      return ''
    end
    last_pitch = (last_note_in_chord || @@last_note)['pitch'][0].to_i
    cur_pitch = note['pitch'][0].to_i
    diff_pitch = cur_pitch - last_pitch

    last_ix = TPC::to_ix((last_note_in_chord || @@last_note)['tpc'][0].to_i)
    cur_ix = TPC::to_ix(note['tpc'][0].to_i)
    diff_ix = (cur_ix - last_ix)%7

    octave_shift = (diff_pitch / 12.0).floor

    diff_pitch = diff_pitch % 12

    if diff_pitch <= 5 #less than perfect fourth
      octave_shift += 0
    elsif diff_pitch == 6 and diff_ix <= 3 #augumented fourth
      octave_shift += 0
    elsif diff_pitch == 6 and diff_ix >= 4 #diminished fifth
      octave_shift += 1
    elsif diff_pitch >= 7
      octave_shift += 1
    end

    octave_shift += @@octavation_diff
    @@octavation_diff = 0

    if octave_shift > 0
      return '\'' * octave_shift.abs
    else
      return ',' * octave_shift.abs
    end
  end
  class <<self
    def reset
      @@last_note = nil
    end
    def setCurrentOctavation(val)
      @@octavation_diff = val - @@current_octavation + @@octavation_diff
      @@current_octavation = val
    end
  end
end
