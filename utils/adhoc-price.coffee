_ = require 'lodash'

important = /[$0-9]/
valuable = /less|than|руб|за|проект|месяц|час|-|([$0-9]+)|hr/i
space = /\s+/
punct = /\.,/g


module.exports = (price) ->

  unless important.test price
    return ''

  price = price.replace punct, ' '

  c = _.filter (price.split space), (p) ->
    valuable.test p

  price = c.join ' '

  price = price.replace ' hr', ' /hr'
