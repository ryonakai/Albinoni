require 'pstore'
require 'digest/sha2'

def readxml(file_name)
  f = File.read(file_name, :encoding => Encoding::UTF_8)
  hash = Digest::SHA256.hexdigest f
  hfn = "xml_cache/#{hash}.dat"
  if File.exists? hfn
    db = PStore.new(hfn)
    db.transaction{|pstore|
      return pstore["data"]
    }
  end

  tags = %w{Rest Ottava number Clef KeySig TimeSig Dynamic Tempo Chord Beam stretch HairPin endSpanner BarLine RehearsalMark StaffText Breath noOffset tick Tuplet vspacerDown LayoutBreak startRepeat Volta endRepeat}
  tags.each do |tag|
    f.gsub!(Regexp.new("<#{tag}(\s|>|/>)"),  '<Tag realTagName=\'' + tag + '\'\1')
    f.gsub!(Regexp.new("</#{tag}(\s|>)"), '</Tag\1')
  end
  f.gsub!("<sym>",  '__sym:')
  f.gsub!("</sym>",  '__')
  f.gsub!("<b>",  '__bold:')
  f.gsub!("</b>",  ':/bold__')
  f.gsub!("<i>",  '__italic:')
  f.gsub!("</i>",  ':/italic__')
  #tags_to_remove = %w{b i}
  #tags_to_remove.each do |tag|
  #  f.gsub!(Regexp.new("</?#{tag}>"), '')
  #end
  elms = []

  x = XmlSimple.xml_in(f, ContentKey:"__content__")
  db = PStore.new(hfn)
  db.transaction{|pstore|
    pstore["data"] = x
  }
  return x
end
