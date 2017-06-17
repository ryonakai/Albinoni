def extract_parts(file_name, use_2)
  return false unless File.exists?(file_name + '.part_list.txt')
  dir, base = File.split file_name

  template_file_specific = file_name + '.template.ly'
  if File.exists? template_file_specific
    puts 'Found specific template file'
    template_file = template_file_specific
  else
    puts 'Specific template file not found; using general template.'
    puts "Specific template can be used : #{file_name}.template.ly"
    template_file = "resources/generalpart_template.ly"
  end

  header_file_name = file_name + '.header.ly'
  header = ''
  if File.exists? header_file_name
    header = File.read header_file_name, :encoding => 'utf-8'
  end
  template_string = File.read template_file, :encoding => 'utf-8'

  partString = 'A'

  part_list = File.read(file_name + '.part_list.txt').split("\n")
  succ_next = false
  ix = 0
  part_list.each do |part|
    next if part[0] == "#"
    partString.succ! if succ_next
    ix += 1
    part_name, file_suffix, short_part_name,  transposition, same = part.split('*').map { |e| e.strip }

    part_name = part_name.gsub('Bb','\bflat').gsub('Eb','\eflat')
  #  part_name = "\\markup{\\override #'(box-padding . 0.8) \\line{ \\magnify #1.6 {#{part_name}}}}"
    music_string = "{\\generalsettings \\compressFullBarRests \\part#{partString} }"
    if !transposition.nil? && !transposition.empty?
      music_string = "{\\generalsettings \\compressFullBarRests \\transpose #{transposition} c { \\part#{partString} }}"
    end
    new_part = template_string.gsub(/<%=\s*part_name\s*%>/, part_name)
    new_part.gsub!(/<%=\s*part_music\s*%>/, music_string)
    new_part.gsub!(/<%=\s*header\s*%>/, "\\header{\n#{header}\n}") unless header.empty?
    file_name_inc = use_2 ? base.gsub('.mscx','2.mscx') : base
    new_part.gsub!(/<%=\s*include_tag\s*%>/, "\\include \"#{base}.ly\"")
    lily_file = "#{file_name}.#{file_suffix}.ly"
    File_safe_write(lily_file, new_part)
    Thread.fork {
      case os
      when :windows
        system "lilypond #{lily_file}"
      when :macosx
        system "/Applications/LilyPond.app/Contents/Resources/bin/lilypond #{lily_file}"
      else
        system "lilypond #{lily_file}"
      end
    }
    succ_next = (same.nil? || same.empty?)
  end
end
