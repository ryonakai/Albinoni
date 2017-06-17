#(set-default-paper-size "a4")
generalsettings =  {
  \override Score.MultiMeasureRest #'expand-limit = #1
  \override Score.RehearsalMark #'font-size = #4.2
  \override Score.MetronomeMark #'font-size = #2.8
  \override Score.BarNumber #'font-size = #5
  \override Score.BarNumber #'self-alignment-X = #0
  \override Score.CombineTextScript #'font-series = #'medium
  \override Score.CombineTextScript #'font-size = #2.4
  \override Score.VoltaBracket #'font-size = #2.2
  \override Score.TextScript #'font-size = #1.8
  \override Score.OttavaBracket #'font-size = #2.2
  \override Score.TupletNumber #'font-size = #1.6
  \override Score.InstrumentName #'font-size = #2.2
  \override Score.InstrumentName #'self-alignment-X = #LEFT
  \set Score.markFormatter = #format-mark-box-barnumbers
  \override Score.RehearsalMark.break-align-symbols = #'(left-edge)
  \override Score.MetronomeMark.outside-staff-priority = #1600
  \override Score.MultiMeasureRest.expand-limit = #2
}


<%= header %>

\include "deutsch.ly"

<%= include_tag %>

\score{
  \new Staff<<
    {\generalsettings \compressFullBarRests <%= part_music %> }
    \new Voice \ds
  >>
  \midi{}
  \layout{}
}

#(set-default-paper-size "a4")
#(set-global-staff-size 20)
\paper {
    indent = 2\cm
    short-indent = 0\cm
    % min-systems-per-page = 8
    % max-systems-per-page = 8
}
