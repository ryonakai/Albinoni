class Signs
  @@bars = {
    "normal"  => '|',
    "double"  => '||',
    "start-repeat"  => '|:',
    "end-repeat"  => ':|',
    "dashed"  => ':',
    "end"  => '|.',
    "end-start-repeat"  => ':|:',
  }
  @@clefs = {
    "F" => "bass",
    "G" => "treble",
    "C3" => "alto",
    "F8vb" => '"bass_8"',
    "G8vb" => '"treble_8"',
  }
  @@keysig_flat = %w{c f b es as des ges ces fes beses eses ases deses geses ceses feses}
  @@keysig_sharp = %w{c g d a e h fis cis gis dis ais eis his fisis}
  @@keysig_offset = [0, -5, 2, -3, 4, -1, 6, 1, -4, 3, -2, 5]
  @@symbols = {
    "segno" => 'scripts.segno',
    "coda" => 'scripts.coda',
    "segnoSerpent1" => 'scripts.varsegno',
    "codaSquare" => 'scripts.varcoda',
    "repeat1Bar" => '',
    "repeat2Bars" => '',
    "repeat4Bars" => '',
    "gClef" => 'clefs.G',
    "fClef" => 'clefs.F',
    "cClef" => 'clefs.C',
    "dynamicPiano" => 'p',
  }
  @@symbols_notes = {
    "unicodeNoteHalfUp" => 2,
    "unicodeNoteQuarterUp" => 4,
    "unicodeNote8thUp" => 8,
    "unicodeNote16thUp" => 16,
    "unicodeNote32ndUp" => 32,
    "unicodeNote64thUp" => 64,
    "unicodeNote128thUp" => 128,
  }
  class << self
    def Bar(bar)
      return {:type => :bar, :text => '\\bar "' + @@bars[bar['subtype'][0]] +  '"'}
    end
    def Breathe()
      return {:type => :breathe, :text => '\\breathe'}
    end
    def BarRaw(barraw)
      return {:type => :bar, :text => '\\bar "' + barraw +  '"'}
    end
    def TimeSig(h)
      Context::setTime(h['sigN'][0].to_i, h['sigD'][0].to_i)
      return {:type => :timesig, :text => "\\time #{h['sigN'][0]}/#{h['sigD'][0]}", :time=>[h['sigN'][0].to_i, h['sigD'][0].to_i]}
    end
    def generalMarkup(str, pos_text = '')
      str = "" if str.empty?
      return {:type => :markup, :text => pos_text + '\\markup{' + process_symbols_in_markup( '"' + str + '"' || '') +  '}'}
    end
    def RehearsalMark(d, text)
      return {:type => :rehearsalmark , :text => '\mark "' + text + '"'}
    end
    def Ottava(d, octave)
      return {:type => :ottava , :text => '\ottava #' + octave.to_s + ''}
    end
    def Clef(d)
      type = d['concertClefType'][0]
      puts type if !@@clefs[type]
      return {:type => :clef, :text => '\clef ' + @@clefs[type]}
    end
    def KeySig(d)
      ks = d['accidental'][0].to_i
      ks += @@keysig_offset[(Context::getTransposition())%12]
      if ks > 0
        k = @@keysig_sharp[ks]
      else
        k = @@keysig_flat[ks.abs]
      end
      return {:type => :keysig, :text => '\key ' + k + '\major'}
    end
    def process_symbols_in_markup(text)
      text.gsub!("__sym:space__","")
      text.gsub!(/[\r\n]/,"")
      @@symbols.each do |k,v|
          text.gsub!("__sym:#{k}__","\" \\markup {\\musicglyph #\"#{v}\"} \"")
      end
      text.gsub!(/__bold:(.*?):\/bold__/, '" \bold{\1} "')
      text.gsub!(/__italic:(.*?):\/italic__/, '" \italic{\1} "')
      #notes
      @@symbols_notes.each do |k,v|
        text.gsub!("__sym:#{k}____sym:unicodeAugmentationDot____sym:unicodeAugmentationDot__","\" \\small \\note #\"#{v}..\" #UP \"")
        text.gsub!("__sym:#{k}____sym:unicodeAugmentationDot__","\" \\small \\note #\"#{v}.\" #UP \"")
        text.gsub!("__sym:#{k}__","\" \\small \\note #\"#{v}\" #UP \"")
      end
      text.gsub!(/\s*\"\"\s*/,'')
      return text
    end
  end
end
