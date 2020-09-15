orcd = require './orcd.coffee'

jest.setTimeout 60000

# Offline test first
test 'build_xml', ->
  comments = [
    { vpos: 1234, user_id: 'abc', message: 'こんばんは' },
    { vpos: 2345, user_id: 'def', message: '待機' },
  ]

  xml = '''<?xml version="1.0"?>
  <packet>
    <chat vpos="1234" user_id="abc">こんばんは</chat>
    <chat vpos="2345" user_id="def">待機</chat>
  </packet>'''

  expect orcd.build_xml comments
    .toBe xml

# Online tests

test 'info_from_url', ->
  info = await orcd.info_from_url 'https://www.openrec.tv/live/o7z4k3qvp8l'
  expect info.id
    .toBe 'o7z4k3qvp8l'

test 'download_comments', ->
  info = await orcd.info_from_url 'https://www.openrec.tv/live/o7z4k3qvp8l'
  comments = await orcd.download_comments info, 0
  expect comments.length
    .toBeGreaterThan 0
