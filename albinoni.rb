require 'xmlsimple'
require 'json'
require 'optparse'

Dir["./lib/*.rb"].each {|file| require file }
require './util/readxml.rb'
require './util/extract_parts.rb'
require './util/make_score.rb'
require './util/misc.rb'

option={}
OptionParser.new do |opt|
  opt.on('-p',   'Make part list only')         {|v| option[:part_only] = v}
  opt.on('-w',   'Overwrite existing part-list')   {|v| option[:overwrite_part] = v}
  opt.on('-x',   'Overwrite existing part-list-for-score')   {|v| option[:overwrite_part_for_score] = v}
  opt.on('-W',   'Overwrite existing markup-list')   {|v| option[:overwrite_markup] = v}
  opt.on('-p',   'Extract part')   {|v| option[:extract_part] = v}
  opt.on('-s',   'Make score')   {|v| option[:make_score] = v}
  opt.on('-2',   'Make score')   {|v| option[:use_2] = v}
  opt.parse!(ARGV)
end

file_name = ARGV[0]

if option[:extract_part]
  extract_parts(file_name, option[:use_2])
  exit
end
if option[:make_score]
  make_score(file_name, option[:use_2])
  exit
end

#
#  Make list of instruments
#

xmldoc = readxml(file_name)
puts "Processing #{file_name} ..."
puts "Finished parsing MuseScore file."

part_list = %q{# List of part for parts.
# comments begin with #.
# 'Bb' and 'Eb' are automatically replaced.
# FORMAT:
# part_name [* transposition] [* same as below = "same"]
# Example
#   Trumpet 1 in Bb * Bb
#   Trumpet 1 in C * * same
#
#}.split '\n'
sc_part_list = %q{# List of part for score.
# comments begin with #.
# 'Bb' and 'Eb' are automatically replaced.
# FORMAT:
# part_name [* transposition]
# Example
#   Trumpet 1 in Bb * Bb
#   Trumpet 1 in C *
#
#}.split '\n'

list_of_parts_in_mscx = xmldoc['Score'][0]['Part'].collect{|item| item['trackName'].join.strip}
part_list += list_of_parts_in_mscx
sc_part_list += list_of_parts_in_mscx
File_safe_write(file_name + '.part_list.txt', part_list.join("\n"), option[:overwrite_part])
File_safe_write(file_name + '.part_list_for_score.txt', sc_part_list.join("\n"), option[:overwrite_part_for_score])

exit if option[:part_only]

#
#  Load XML and convert to Lilypond file
#

ly_text = "%Made with mscz2ly\n\\version \"2.18.2\"\n\\include \"deutsch.ly\"\n"
ly_parts = []
tagnames = []
partString = 'A'

#
#  Get instrument transpositions
#
transpositions = []
xmldoc['Score'][0]['Part'].each do |element|
  id = element['Staff'][0]['id'].to_i
  transpositions[id] = element['Instrument'][0]['transposeChromatic'][0].to_i rescue 0
end

test_buffer = []

#
#  Prepare markup list to clarify if each markup should be dealt with as part-specific or global
#
markup_list = "Add \'1\' to the ending of line which contains the markup you think is in fact a tempo.\n"
if File.exists?(file_name + '.markup_list.txt')
  markup_list_read = File.read(file_name + '.markup_list.txt' , :encoding => 'utf-8')
else
  markup_list_read = nil
end

#
#
#
yet_no_ds = true


#
#  Part-wise reading
#
xmldoc['Score'][0]['Staff'].each do |element|
  #
  # Beginning of part staff
  #
  id = element['id'].to_i
  puts "Processing part ##{id}..."

  ly_parts[id] = {}
  ly_parts[id][:transposition] = transpositions[id]
  LilyBuffer::reset
  LilyNote::reset
  #LilyBuffer::add "part#{partString} = {\n\t"

  last_bar = false
  Context::reset
  Context::setTransposition(transpositions[id] || 0)

  element['Measure'].each do |measure_content|
    #
    #  Beggining of Measure
    #

    #  Reset previous length of note
    Context::setLastLength('***')

    #
    #  Loop for contents within the measure
    #
    next if !measure_content['Tag']
    measure_content['Tag'].each do |vh|
      longhash = LilyBuffer::getAndUpdateCurrentSHA256(vh)
      shorthash = longhash[0,12]

      key = vh['realTagName']

      #
      # Process "text" and "beginText" attribute of item
      # to deal with it as a simple string
      #
      if vh["text"]
        vt = vh["text"][0]['__content__'] || vh["text"][0]
        if vt.instance_of?(Array)
          text = vt.join
        else
          text = vt
        end
      end
      if vh['beginText'] && vh['useTextLine'] && vh['beginText'][0]['text']
        text = vh['beginText'][0]['text'].join
        txt = Signs::generalMarkup('"\italic "' + text + '""', '_')[:text]
        Context::addToStack(txt)
        next
      end

      case key
      when 'Chord', 'Rest'
        #  Process notes and rests
        ln = LilyNote.new vh
        l = ln.to_lily
        LilyBuffer::add l
        pending_text = ''
      when 'StaffText'
        if markup_list_read and Regexp.new("#{shorthash}\s+1$").match(markup_list_read)
          #  Process as tempo, i.e. this appears to all parts
          LilyBuffer::add ({:type => :tempo, :markup => Signs::generalMarkup(text)})
        else
          #  Process as part-specific instruction
          pos_text = (vh['pos'][0]['y'].to_f rescue -1) < 0 ? '^' : '_'
          txt = Signs::generalMarkup(text, pos_text)[:text]
          Context::addToStack(txt)
        end
        markup_list << "#{txt}\t\t\t\t#{shorthash} \n"
      when 'Ottava'
        #  Display "8va" line
        LilyBuffer::add Signs::Ottava(vh, -1)
        Context::setEnd(vh, '__endOttava__')
        #  Apply octavation when reading notes
        LilyNote::setCurrentOctavation(-1)
      when 'BarLine'
        LilyBuffer::add Signs::Bar(vh)
        last_bar = true  # To avoid processing bar line twice
      when 'TimeSig'
        LilyBuffer::add Signs::TimeSig(vh)
      when 'Tempo'
        LilyBuffer::add ({:type => :tempo, :markup => Signs::generalMarkup(text)})
      when 'Tuplet'
        LilyBuffer::add Context::startTuplet(vh)
      when 'RehearsalMark'
        LilyBuffer::add Signs::RehearsalMark(vh, text)
      when 'Clef'
        LilyBuffer::add Signs::Clef(vh)
      when 'KeySig'
        LilyBuffer::add Signs::KeySig(vh)
      when 'Breath'
        LilyBuffer::add Signs::Breathe()
      when 'HairPin'
        Context::Start(key, vh)
      when 'endSpanner'
        #  End some spanner, specified with id
        the_id = vh["id"].to_i
        Context::Ending(the_id)
      when 'Slur'
        #  Do nothing because slurs are processed within subroutines of chord and rest
      when 'stretch', 'LayoutBreak', 'noOffset', 'tick', 'vspacerDown', 'vspacerUp'
        #  Do nothing because these are only for MuseScore displaying
      when 'startRepeat'
        LilyBuffer::add Signs::BarRaw("|:")
        last_bar = true
      when 'Dynamic'
        Pending::setDynamic vh
      else
        tagnames.push key
      end
      #File.write('debug.ly',ly_text)
    end
    #  End of a measure
    LilyBuffer::add ({type: :bar, barType: :normal}) unless last_bar  # To avoid processing bar line twice
    last_bar = false
  end
  LilyBuffer::add ({type: :stack, text:Context::getStack}) #  End all contexts
  ly_parts[id][:contets] = LilyBuffer::getAll
  text, ds_text = LilyBuffer::expandText
  if yet_no_ds
    ly_text << "ds = " + ds_text + "\n\n"
    yet_no_ds = false
  end
  ly_text << "part#{partString} = " + text + "\n\n"
  partString.succ!
end
#File_safe_write(file_name + '.json',             JSON.generate(LilyBuffer::getAll))
File_safe_write(file_name + '.ly',               ly_text)
File_safe_write(file_name + '.markup_list.txt',  markup_list, option[:overwrite_markup])
#File_safe_write('tests.json', JSON.generate(test_buffer))

if tagnames.length > 0
  puts ''
  puts 'Following tags were not processed:'
  puts tagnames.uniq.join ', '
end
