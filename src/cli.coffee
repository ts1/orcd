{ orcd } = require './orcd'
ass = require './ass'

args = require 'yargs'
  .command '$0 <url|file>', '動画のコメントを取得または変換します',
    (yargs) ->
      yargs
        .positional 'url|file',
          desc: 'ダウンロードURL、または変換元ファイル'
          type: 'string'
  .option 'delay',
    alias: 'd'
    desc: '時間のずれ(秒)'
    type: 'number'
    default: 0
  .option 'norandom',
    alias: 'R'
    desc: '秒以下を乱数化しない'
    type: 'boolean'
  .option 'format',
    alias: 'f'
    desc: '出力フォーマット'
    choices: ['xml', 'ass', 'json']
    default: 'xml'
  .option 'output',
    alias: 'o'
    desc: '出力ファイル名'
    type: 'string'
    default: 'auto'
  .group ['fontname', 'fontsize', 'margin', 'outline', 'time'],
    'ASSオプション:'
  .option 'fontname',
    alias: 'F'
    desc: 'フォント名'
    type: 'string'
    default: ass.DEFAULTS.font_name
  .option 'fontsize',
    alias: 's'
    desc: 'フォントサイズ(px)'
    type: 'number'
    default: ass.DEFAULTS.font_size
  .option 'margin',
    alias: 'm'
    desc: '上下のマージン(px)'
    type: 'number'
    default: ass.DEFAULTS.margin
  .option 'outline',
    alias: 'O'
    desc: '文字のアウトライン(px)'
    type: 'number'
    default: ass.DEFAULTS.outline
  .option 'time',
    alias: 't'
    desc: 'コメント1個の表示時間(秒)'
    type: 'number'
    default: ass.DEFAULTS.displayed_time
  .option 'debug',
    alias: 'D'
    desc: 'デバッグモード'
    type: 'boolean'
  .help()
  .alias 'help', 'h'
  .alias 'version', 'v'
  .strict()
  .argv

do ->
  try
    await orcd args
  catch e
    console.error e.message or e
    throw e if args.debug
    process.exit 1
