class Duration
    @@dur_to_lily = {
      'quarter'  => '4',
      'eighth'  => '8',
      '1024th'  => '1024',
      '512th'  => '512',
      '256th'  => '256',
      '128th'  => '128',
      '64th'  => '64',
      '32nd'  => '32',
      '16th'  => '16',
      'half'  => '2',
      'whole'  => '1',
      'measure'  => '',
      'breve'  => '\breve',
      'long'  => '',
    }
    def self.to_lily( *args )
      return unless args.count == 2
      duration_text, dot_count = args
      return  @@dur_to_lily[duration_text] + ("." * dot_count.to_i)
    end
end
