# MuseScore/libmscore/mscore.h
class Articulation
  @@art2ly = {
    'fermata' => ',',
    'shortfermata' => '\shortfermata',
    'longfermata' => '\longfermata',
    'verylongfermata' => '\verylongfermata',
    'sforzatoaccent' => '->',
    'sforzato' => '->',
    'staccato' => '-.',
    'staccatissimo' => '-!',
    'tenuto' => '--',
    'portato' => '-_',
    'marcato' => '^^',
    'fadein' => '',
    'fadeout' => '',
    'volumeswell' => '',
    'wigglesawtooth' => '',
    'wigglesawtoothwide' => '',
    'wigglevibratolargefaster' => '',
    'wigglevibratolargeslowest' => '',
    'ouvert' => '',
    'plusstop' => '-+',
    'upbow' => '\upbow',
    'downbow' => '\downbow',
    'reverseturn' => '',
    'turn' => '',
    'trill' => '\trill',
    'prall' => ',',
    'mordent' => ',',
    'prallprall' => ',',
    'prallmordent' => ',',
    'upprall' => ',',
    'downprall' => ',',
    'upmordent' => ',',
    'downmordent' => ',',
    'pralldown' => ',',
    'prallup' => ',',
    'lineprall' => ',',
    'schleifer' => '',
    'snappizzicato' => '',
    'thumbposition' => '',
    'lutefingthumb' => '',
    'lutefingfirst' => '',
    'lutefingsecond' => '',
    'lutefingthird' => '',
  }
  def self.to_lily(articulation)
    articulation.downcase!
    @@art2ly[articulation] = '\\' + articulation if @@art2ly[articulation] == ','
    return @@art2ly[articulation];
  end
end
