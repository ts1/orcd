DEFAULTS =
  font_name: 'MS PGothic'
  font_size: 48
  margin: 4
  outline: 2
  displayed_time: 8

WIDTH = 1280
HEIGHT = 720

HEADER = """
[Script Info]
ScriptType: v4.00+
PlayResX: #{WIDTH}
PlayResY: #{HEIGHT}
WrapStyle: 2
ScaledBorderAndShadow: Yes
Timing: 100.0000

"""

EVENTS_HEADER = '''

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
'''

build_style = (opt) ->
  style =
    Name: 'style'
    Fontname: opt.font_name
    Fontsize: opt.font_size
    PrimaryColour: '&H00FFFFFF'
    SecondaryColour: '&H00FFFFFF'
    OutlineColour: '&H80000000'
    BackColour: '&H00000000'
    Bold: -1
    Italic: 0
    Underline: 0
    StrikeOut: 0
    ScaleX: 100
    ScaleY: 100
    Spacing: 0
    Angle: 0
    BorderStyle: 1
    Outline: opt.outline
    Shadow: 0
    Alignment: 7
    MarginL: 0
    MarginR: 0
    MarginV: 0
    Encoding: 1

  """
  [V4+ Styles]
  Format: #{Object.keys(style).join(', ')}
  Style: #{Object.values(style).join(',')}
  """

collision_at_start = (first, second, opt) ->
  len = first.message.length * opt.font_size
  speed = (WIDTH + len) / (opt.displayed_time * 100)
  time = second.vpos - first.vpos
  first_pos_when_second_starts = speed * time
  margin = opt.font_size / 2
  len + margin - first_pos_when_second_starts

collision_at_end = (first, second, opt) ->
  first_ends_at = first.vpos + opt.displayed_time * 100
  len = second.message.length * opt.font_size
  speed = (WIDTH + len) / (opt.displayed_time * 100)
  time = first_ends_at - second.vpos
  second_pos_when_first_ends = speed * time
  second_pos_when_first_ends - WIDTH

collision = (first, second, opt) ->
  return 0 unless first
  return 0 unless second
  start = collision_at_start first, second, opt
  end = collision_at_end first, second, opt
  if start > end then start else end

to_hms = (t) ->
  zerofill = (x) -> ('0' + x).substr -2
  ss = zerofill(t % 100)
  t = Math.floor(t / 100)
  s = zerofill(t % 60)
  t = Math.floor(t / 60)
  m = zerofill(t % 60)
  h = Math.floor(t / 60)
  "#{h}:#{m}:#{s}.#{ss}"

build_events = (list, opt) ->
  lineheight = opt.font_size + opt.margin * 2
  n_normal_rows = Math.floor((HEIGHT + opt.margin) / lineheight)
  n_wrap_rows = Math.floor((HEIGHT + opt.margin - lineheight / 2) / lineheight)
  n_rows = n_normal_rows + n_wrap_rows
  item_in_row = (null for i in [0...n_rows])
  list.map (item, index) ->
    row = null
    min_collision = Infinity
    for i in [0...n_rows]
      c = collision item_in_row[i], item, opt
      if c <= 0
        row = i
        break
      if c < min_collision
        min_collision = c
        row = i

    item_in_row[row] = item

    start = to_hms item.vpos
    end = to_hms(item.vpos + opt.displayed_time * 100)
    len = item.message.length * opt.font_size
    x0 = WIDTH
    x1 = -len
    y =
      if row < n_normal_rows
        opt.margin + row * (opt.font_size + opt.margin * 2)
      else
        lineheight / 2 + opt.margin +
          (row - n_normal_rows) * (opt.font_size + opt.margin * 2)
    effect = "{\\move(#{x0},#{y},#{x1},#{y})}"

    'Dialogue: ' + [
      index
      start
      end
      'style'
      item.user_id.replace ',', '_'
      '0000'
      '0000'
      '0000'
      ''
      "#{effect}#{item.message}"
    ].join ','
  .join '\n'

build = (list, options = {}) ->
  opt = { DEFAULTS..., options... }
  [
    HEADER
    build_style opt
    EVENTS_HEADER
    build_events list, opt
  ].join '\n'
    

module.exports = { DEFAULTS, build }
