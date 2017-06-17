#(set-default-paper-size "a4")
generalsettings =  {
  \override Score.MultiMeasureRest #'expand-limit = #1
  \override Score.RehearsalMark #'font-size = #4.2
  \override Score.MetronomeMark #'font-size = #2.8
  \override Score.BarNumber #'font-size = #5
  \override Score.BarNumber #'font-shape = #'italic
  \override Score.CombineTextScript #'font-series = #'medium
  \override Score.CombineTextScript #'font-size = #2.4
  \override Score.VoltaBracket #'font-size = #2.2
  \override Score.TextScript #'font-size = #1.8
  \override Score.OttavaBracket #'font-size = #2.2
  \override Score.TupletNumber #'font-size = #2.2
  \override Score.InstrumentName #'font-size = #2.2
  \override Score.InstrumentName #'self-alignment-X = #LEFT
  \set Score.markFormatter = #format-mark-box-barnumbers
}

<%= header %>

\include "deutsch.ly"

<%= include_tag %>

\score{
<<
  \new ChoirStaff<<
  <%= parts_string %>
  >>
>>
  \midi{}
  \layout{}
}

#(set-default-paper-size "a4")
#(set-global-staff-size 18)
instrnm = "Score"
\paper {
    indent = 5\cm
    short-indent = 4\cm
    ragged-last-bottom = ##f
    ragged-last = ##f
}
