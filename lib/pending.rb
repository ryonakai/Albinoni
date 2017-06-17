class Pending
  @@dynamic = ''
  class << self
    def setDynamic(d)
      if d['subtype'][0] == 'other-dynamics'
        @@dynamic = "\\markup{\"#{ d['text'][0]}\"}"
      else
        @@dynamic = '\\' + d['subtype'][0]
      end
    end
    def getDynamic
      rval = @@dynamic
      @@dynamic = ''
      return rval
    end
  end
end
