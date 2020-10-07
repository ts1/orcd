orcd = require '../src/orcd'

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
