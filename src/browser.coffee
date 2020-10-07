import { info_from_url, download_comments, randomize } from './download'
import { build } from './ass'

save = (filename, s) ->
  blob = new Blob [s], type: 'text/plain'
  a = document.createElement 'a'
  a.download = filename
  a.href = URL.createObjectURL blob
  a.click()

show_downloading = ->
  e = document.createElement 'div'
  e.id = 'orcd-downloading'
  e.innerText = 'コメントをダウンロード中...'
  s = e.style
  s.position = 'fixed'
  s.width = '100%'
  s.top = s.left = 0
  s.textAlign = 'center'
  s.padding = '16px'
  s.fontSize = '32px'
  s.fontWeight = 'bold'
  s.zIndex = 99999999
  s.color = '#333'
  s.backgroundColor = '#fff'
  s.boxShadow = '0 0 40px #000'
  document.body.append e

remove_downloading = ->
  document.querySelector('#orcd-downloading')?.remove()

do ->
  try
    show_downloading()
    info = await info_from_url window.location.href
    comments = await download_comments info
    randomize comments
    ass = build comments
    save "#{info.title}.ass", ass
    remove_downloading()
  catch e
    remove_downloading()
    alert e.message
