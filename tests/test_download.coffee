{ info_from_url, download_comments } = require '../src/download'

jest.setTimeout 60000

test 'info_from_url', ->
  info = await info_from_url 'https://www.openrec.tv/live/o7z4k3qvp8l'
  expect info.id
    .toBe 'o7z4k3qvp8l'

test 'download_comments', ->
  info = await info_from_url 'https://www.openrec.tv/live/o7z4k3qvp8l'
  comments = await download_comments info, 0
  expect comments.length
    .toBeGreaterThan 0
