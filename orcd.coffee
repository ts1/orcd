path = require 'path'
fs = require 'fs'
fetch = require 'node-fetch'
{ create } = require 'xmlbuilder2'
xml2js = require 'xml2js'

get_json = (url) ->
  res = await fetch url
  throw new Error await res.text() unless res.ok
  res.json()

write_tty = (s) -> process.stderr.write s if process.stderr.isTTY

show_progress = (progress) ->
  w = process.stderr.columns - 7
  bar = '░'.repeat Math.round(w * progress)
  bar += '─'.repeat w - bar.length
  percent = Math.round(99 * progress)
  write_tty "\r[#{bar}] #{percent}%"

info_from_url = (url) ->
  unless /^https?:\/\/www\.openrec\.tv\/live\//.test url
    throw new Error 'URLが正しくありません'
  video_id = url.split('/').slice(-1)[0]
  await get_json 'https://public.openrec.tv/external/api/v5/movies/' + video_id

download_comments = (info, delay) ->
  start_at = new Date info.started_at
  end_at = new Date info.ended_at
  t = new Date start_at
  t.setSeconds t.getSeconds() + delay
  list = []
  ids = {}
  while true
    url = "https://public.openrec.tv/external/api/v5/movies/#{info.id}/chats?"+
     "from_created_at=#{t.toISOString()}&is_including_system_message=false"
    chats = await get_json url
    new_chat = false
    for chat in chats
      continue if ids[chat.id]
      ids[chat.id] = true
      new_chat = true
      posted_at = new Date chat.posted_at
      vpos = (posted_at.getTime() - start_at.getTime()) / 10 - delay * 100
      continue if vpos < 0
      user_id = chat.user.id
      list.push { vpos, user_id, message: chat.message }
    t = new Date chats.slice(-1)[0].posted_at
    progress = (t.getTime() - start_at.getTime()) /
      (end_at.getTime() - start_at.getTime())
    show_progress progress
    break unless new_chat
  list

parse_xml = (content) ->
  try
    xml = await xml2js.parseStringPromise content
  catch e
    return null
  list = xml.packet?.chat
  return null unless list
  { chat.$..., message: chat._ } for chat in list

load_file = (filename) ->
  filename = process.stdin.fd if filename == '-'
  content = fs.readFileSync filename, 'utf8'

  try return JSON.parse content catch

  list = await parse_xml content
  return list if list

  throw new Error '入力ファイルのフォーマットが未対応です'

randomize = (list) ->
  for chat in list
    if chat.vpos % 100 == 0
      chat.vpos += Math.floor(Math.random() * 100)
  return

build_xml = (list) ->
  root = create(version: '1.0').ele('packet')
  for item in list
    root.ele('chat', vpos: item.vpos, user_id: item.user_id).txt(item.message)
  root.end prettyPrint: true

main = ->
  argv = require 'yargs'
    .command '$0 <url|file>', '動画のコメントを取得または変換します',
      (yargs) ->
        yargs
          .positional 'url',
            desc: '動画URL'
            type: 'string'
          .positional 'file',
            desc: '変換元ファイル'
            type: 'string'
    .option 'delay',
      alias: 'd'
      desc: '時間のずれ(秒)'
      type: 'number'
      default: 15
    .option 'norandom',
      alias: 'R'
      desc: '秒以下を乱数化しない'
      type: 'boolean'
    .option 'format',
      alias: 'f'
      desc: '出力フォーマット'
      choices: ['xml', 'json']
      default: 'xml'
    .option 'output',
      alias: 'o'
      desc: '出力ファイル名'
      type: 'string'
      default: 'auto'
    .help()
    .alias 'help', 'h'
    .alias 'version', 'v'
    .argv

  if /^https?:\/\//.test argv.url
    info = await info_from_url argv.url
    title = info.title
    console.warn "Loading comments for '#{info.title}'."
    list = await download_comments info, argv.delay
  else
    list = await load_file argv.file
    title = path.basename argv.file
    if '.' in title
      title = title.split('.').slice(0, -1).join('.')

  randomize list unless argv.norandom
  list.sort (a, b) -> a.vpos - b.vpos

  filename =
    if argv.output == 'auto'
      filename = "#{title}.#{argv.format}"
    else
      argv.output

  if filename == argv.file
    throw new Error '出力ファイル名が入力ファイルと同じです'

  output =
    if argv.format == 'xml'
      build_xml list
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

module.exports = { info_from_url, download_comments, build_xml }

if require.main == module
  do ->
    try
      await main()
    catch e
      console.error e.message or e
      process.exit 1
