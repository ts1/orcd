path = require 'path'
fs = require 'fs'
{ create } = require 'xmlbuilder2'
xml2js = require 'xml2js'
{ info_from_url, download_comments, randomize } = require './download'
ass = require './ass'

write_tty = (s) -> process.stderr.write s if process.stderr.isTTY

show_progress = (progress) ->
  w = process.stderr.columns - 7
  bar = '░'.repeat Math.round(w * progress)
  bar += '─'.repeat w - bar.length
  percent = Math.round(99 * progress)
  write_tty "\r[#{bar}] #{percent}%"

parse_xml = (content) ->
  try
    xml = await xml2js.parseStringPromise content
  catch e
    return null
  list = xml.packet?.chat
  return null unless list

  for chat in list
    vpos = Number chat.$.vpos
    user_id = chat.$.user_id
    message = chat._ or ''
    { vpos, user_id, message }

load_file = (filename) ->
  filename = process.stdin.fd if filename == '-'
  content = fs.readFileSync filename, 'utf8'

  try return JSON.parse content catch

  list = await parse_xml content
  return list if list

  throw new Error '入力ファイルのフォーマットが未対応です'

add_delay = (list, delay) ->
  list
    .map (item) -> { item..., vpos: item.vpos - (delay * 100) }
    .filter (item) -> item.vpos >= 0

build_xml = (list) ->
  root = create(version: '1.0').ele('packet')
  for item in list
    root.ele('chat', vpos: item.vpos, user_id: item.user_id).txt(item.message)
  root.end prettyPrint: true

orcd = (args) ->
  if /^https?:\/\//.test args.url
    info = await info_from_url args.url
    title = info.title
    console.warn "Loading comments for '#{info.title}'."
    list = await download_comments info, show_progress
  else
    list = await load_file args.file
    title = path.basename args.file
    if '.' in title
      title = title.split('.').slice(0, -1).join('.')

  randomize list unless args.norandom
  list = add_delay list, args.delay

  filename =
    if args.output == 'auto'
      filename = "#{title}.#{args.format}"
    else
      args.output

  if filename == args.file
    throw new Error '出力ファイル名が入力ファイルと同じです'

  output =
    if args.format == 'xml'
      build_xml list
    else if args.format == 'ass'
      ass.build list,
        font_name: args.fontname
        font_size: args.fontsize
        margin: args.margin
        outline: args.outline
        displayed_time: args.time
    else
      JSON.stringify list

  write_tty '\r'
  process.stderr.write "Saving to '#{filename}': "
  write_tty '\x1b[K'

  if filename == '-'
    process.stdout.write output
  else
    fs.writeFileSync filename, output

  process.stderr.write 'done.\n'

module.exports = {
  randomize
  build_xml
  orcd
}
