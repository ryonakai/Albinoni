class TPC
  # note that index starts with -1
  # https://musescore.org/plugin-development/tonal-pitch-class-enum
  @@tpc_to_lily =  ['feses','ceses','geses','deses','ases','eses','heses',
                        'fes','ces','ges','des','as','es','b',
                        'f','c','g','d','a','e','h',
                        'fis','cis','gis','dis','ais','eis','his',
                        'fisis','cisis','gisis','disis','aisis','eisis','hisis'];
  @@tpc_to_ix = [4,1,5,2,6,3,7];
  def self.to_tone_name(tpc)
    return @@tpc_to_lily[tpc + 1]
  end
  def self.to_ix(tpc)
    return @@tpc_to_ix[(tpc + 1) % 7]
  end
end
