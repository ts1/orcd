path = require 'path'
fs = require 'fs'
fetch = require 'node-fetch'
{ create } = require 'xmlbuilder2'

get_json = (url) ->
  res = await fetch url
  throw new Error await res.text() unless res.ok
  res.json()

write_tty = (s) -> process.stderr.write s if process.stderr.isTTY

show_progress = (progress) ->
  return unless process.stderr.isTTY
  w = process.stderr.columns - 7
  bar = '░'.repeat Math.round(w * progress)
  bar += '─'.repeat w - bar.length
  percent = Math.round(99 * progress)
  write_tty "\r[#{bar}] #{percent}%"

info_from_url = (url) ->
  unless url.startsWith 'https://www.openrec.tv/'
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

randomize = (list) ->
  for chat in list
    chat.vpos += Math.floor(Math.random() * 100)
  return

build_xml = (list) ->
  root = create(version: '1.0').ele('packet')
  for item in list
    root.ele('chat', vpos: item.vpos, user_id: item.user_id).txt(item.message)
  root.end prettyPrint: true

main = ->
  argv = require 'yargs'
    .command '$0 URL', '動画のコメントを取得します', (yargs) ->
      yargs.positional 'URL',
        desc: '動画URL'
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
    .help()
    .alias 'help', 'h'
    .argv

  info = await info_from_url argv.URL

  console.warn "Loading comments for '#{info.title}'."
  list = await download_comments info, argv.delay

  randomize list unless argv.norandom

  list.sort (a, b) -> a.vpos - b.vpos

  xml = build_xml list
  filename = "#{info.title}.xml"
  fs.writeFileSync filename, xml

  write_tty '\r'
  process.stderr.write "✔ Saved to '#{filename}'."
  write_tty '\x1b[K'
  process.stderr.write '\n'

module.exports = { info_from_url, download_comments, build_xml }

if require.main == module
  do ->
    try
      await main()
    catch e
      console.error e.message or e
      process.exit 1
