const coffee = require('coffeescript')

module.exports = {
  process: (src, path) => {
    if (coffee.helpers.isCoffee(path))
      return coffee.compile(src, {bare: true})
    else
      return src
  }
}
