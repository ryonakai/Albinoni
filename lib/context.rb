class Context
  class << self
    def reset
      @@time = [4,4]
      @@key = [1,1] # C Major
      @@last_length_lily = '***'
      @@stack = ''
      @@endingStack = ''
      @@transposition = 0
      @@ends = []
      @@tuplets = []
    end
    def setTime(a,b)
      #  Set time signature
      @@time = [a,b]
    end
    def getFullMeasureLengthText()
      #  Get text representing length of measure
      #  e.g. '1' for 4/4, '2' for 2/4, '4.' for 3/8, etc.
      a = @@time[0]
      b = @@time[1]
      for i in [1,2,4,8,16,32]
        if i * a == b
          return i.to_s
        elsif i * a == b * 1.5
          return i.to_s + '.'
        else
          return  "1*#{a}/#{b}"
        end
      end
    end
    def setLastLength(length)
      @@last_length_lily = length
    end
    def compareLastLength(length)
      #  Omit length numeric if length is same as previous note
      return @@last_length_lily == length ? '' : length
    end
    def Start(name,val)
      subtype = val['subtype'] ? val['subtype'][0] : ''
      id = val['id'].to_i
      case name
      when 'HairPin'
        if subtype == '0'
          stack = '\<'
        else
          stack = '\>'
        end
        @@ends[id] = '\!'
        @@stack <<  stack
      when 'Ottava'
        stack = ', \ottava #-1'
        @@ends[id] =  ' \ottava #0'
        @@stack = stack  + @@stack
      end
    end
    def setEnd(vh, text)
      id = vh['id'].to_i
      @@ends[id] = text
    end
    def addToStack(text)
      @@stack <<  text
    end
    def Ending(id)
      if @@ends[id]
        if @@ends[id] == '__endOttava__'
          #  Reset octavation
          LilyBuffer::add Signs::Ottava(nil, 0)
          LilyNote::setCurrentOctavation(0)
        else
          @@endingStack <<  @@ends[id]
        end
      end
    end
    def getStack
      st = @@stack
      @@stack = ''
      return st
    end
    def getEndingStack
      st = @@endingStack
      @@endingStack = ''
      return st
    end
    def setTransposition(val)
      #  e.g. val = -2 if noted in Bb
      @@transposition = val
    end
    def getTransposition
      return @@transposition
    end
    def startTuplet(vh)
      text = "\\times #{vh["normalNotes"][0]}/#{vh["actualNotes"][0]}{"
      @@tuplets.push vh['id']
      return {:type => :tuplet, :id => vh['id'], :text => text}
    end
    def endTuplet(id)
      LilyBuffer::addNoteStack('}')
      @@tuplets.delete id
    end
    def checkTuplets(tuplets)
      @@tuplets.each do |t|
        endTuplet(t) unless (tuplets || []).include?(t)
      end
    end
  end
end
