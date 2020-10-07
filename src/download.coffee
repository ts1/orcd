fetch =
  if process? and require?
    require 'node-fetch'
  else
    window.fetch

get_json = (url) ->
  res = await fetch url
  throw new Error await res.text() unless res.ok
  res.json()

exports.info_from_url = (url) ->
  unless /^https?:\/\/www\.openrec\.tv\/live\//.test url
    throw new Error 'URLが正しくありません'
  video_id = url.split('/').slice(-1)[0]
  await get_json 'https://public.openrec.tv/external/api/v5/movies/' + video_id

exports.download_comments = (info, show_progress) ->
  start_at = new Date info.started_at
  end_at = new Date info.ended_at
  t = start_at
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
      vpos = (posted_at.getTime() - start_at.getTime()) / 10
      continue if vpos < 0
      user_id = chat.user.id
      list.push { vpos, user_id, message: chat.message }
    t = new Date chats.slice(-1)[0].posted_at
    progress = (t.getTime() - start_at.getTime()) /
      (end_at.getTime() - start_at.getTime())
    show_progress progress if show_progress
    break unless new_chat
  list

exports.randomize = (list) ->
  for chat in list
    if chat.vpos % 100 == 0
      chat.vpos += Math.floor(Math.random() * 100)
  list.sort (a, b) -> a.vpos - b.vpos
