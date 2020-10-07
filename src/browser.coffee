import { info_from_url, download_comments, randomize } from './download.coffee'
import { build } from './ass.coffee'

save = (filename, s) ->
  blob = new Blob [s], type: 'text/plain'
  a = document.createElement 'a'
  a.download = filename
  a.href = URL.createObjectURL blob
  a.click()

do ->
  try
    info = await info_from_url window.location.href
    comments = await download_comments info
    randomize comments
    ass = build comments
    save "#{info.title}.ass", ass
  catch e
    alert e.message
