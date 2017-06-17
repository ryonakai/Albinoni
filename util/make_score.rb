def make_score(file_name, use_2 = false)
    template_file_specific = file_name + '.score_template.ly'
    if File.exists? template_file_specific
      puts 'Found specific template file'
      template_file = template_file_specific
    else
      puts 'Specific template file not found; using general template.'
      puts 'Specific template can be used : <file_name.mscx>.score_template.ly'
      template_file = "resources/generalscore_template.ly"
    end
    template_string = File.read template_file, :encoding => 'utf-8'

    score_header_file_name = file_name + '.score_header.ly'
    header_file_name = file_name + '.header.ly'
    header = ''
    if File.exists? score_header_file_name
      header = File.read(score_header_file_name, :encoding => 'utf-8')
    elsif  File.exists? header_file_name
      header = File.read(header_file_name, :encoding => 'utf-8')
    end

    partString = 'A'
    parts_string = ''

    part_list = File.read(file_name + '.part_list_for_score.txt').split("\n")
    part_list.each_with_index do |part, ix|
      next if part[0] == "#"
      if part[0] == "-"
        parts_string << %Q{  >>\n  \\new ChoirStaff<<\n}
        next
      end
      part_name, short_part_name, transposition = part.split('*').map { |e| e.strip }

      part_name = part_name.gsub('Bb','\bflat').gsub('Eb','\eflat')
      short_part_name = (short_part_name || part_name).gsub('Bb','\bflat').gsub('Eb','\eflat')
      part_name = "\\markup{#{part_name}}"
      short_part_name = "\\markup{#{short_part_name}}"

      music_string = "\\part#{partString}"
      if !transposition.nil? && !transposition.empty?
        music_string = "\\transpose #{transposition} c { \\part#{partString} }"
      end

      parts_string << %Q{    \\new Staff  {
       \\set Staff.instrumentName = #{part_name}
       \\set Staff.shortInstrumentName = #{short_part_name}
       \\generalsettings #{music_string}
    }
}
      partString.succ!

    end
    new_score = template_string.gsub(/<%=\s*parts_string\s*%>/, parts_string.rstrip)
    new_score.gsub!(/<%=\s*include_tag\s*%>/, "\\include \"#{file_name}.ly\"")
    new_score.gsub!(/<%=\s*header\s*%>/, "\\header{\n#{header}\n}") unless header.empty?
    lily_file = "#{file_name}.score.ly"
    File_safe_write(lily_file, new_score)
end
