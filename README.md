# Albinoni: Music processing software
**Albinoni** is an open source music processor.
Albinoni processes [MuseScore](https://musescore.org/) and [Lilypond](http://lilypond.org/) format files.

## Features
- Converts MuseScore (Version 2) file to Lilypond source
- Generates human-readable Lilypond code
- Produces score and part sources at once
- Custom templates can be applied to score and part sources

## License
**Albinoni** is Licensed under GPL version 3.0.

## Requirements
**Albinoni** requires `digest/sha2`, `xmlsimple`, `json`, `optparse`, `pstore`.

## Running
`ruby albinoni.rb /path/to/some/music.mscx`

Note that input file should be `.mscx` format, not `.mscz`.
When finished, lilypond output will be saved on `/path/to/some/music.mscx.ly`.
