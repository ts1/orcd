import commonjs from '@rollup/plugin-commonjs'
import json from '@rollup/plugin-json'
import coffee from 'rollup-plugin-coffee-script'
import { terser } from "rollup-plugin-terser";

export default {
  input: 'src/browser.coffee',
  output: {
    globals: {
      'node-fetch': 'null'
    },
    format: 'iife',
    file: 'browser/orcd.js'
  },
  plugins: [
    coffee(),
    json(),
    commonjs({ extensions: ['.js', '.coffee'] }),
    terser()
  ],
  external: ['node-fetch']
}
