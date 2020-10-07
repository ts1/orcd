ass = require '../src/ass.coffee'
{ version } = require '../package.json'

test 'build', ->
  comments = [
    { vpos: 1234, user_id: 'abc', message: 'こんばんは' },
    { vpos: 2345, user_id: 'def', message: '待機' },
  ]

  expected = """
    [Script Info]
    ScriptType: v4.00+
    PlayResX: 1280
    PlayResY: 720
    WrapStyle: 2
    ScaledBorderAndShadow: Yes
    Timing: 100.0000

    [V4+ Styles]
    Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
    Style: style,MS PGothic,48,&H00FFFFFF,&H00FFFFFF,&H80000000,&H00000000,-1,0,0,0,100,100,0,0,1,2,0,7,0,0,0,1

    [Events]
    Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
    Dialogue: 0,0:00:12.34,0:00:20.34,style,abc,0000,0000,0000,,{\\move(1280,4,-240,4)}こんばんは
    Dialogue: 1,0:00:23.45,0:00:31.45,style,def,0000,0000,0000,,{\\move(1280,4,-96,4)}待機"""

  expect ass.build comments, {}
    .toBe expected
