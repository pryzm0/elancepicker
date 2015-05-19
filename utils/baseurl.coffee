URL = require 'url'
path = require 'path'
_ = require 'lodash'

module.exports = (href, origin) ->
  origin = URL.parse(origin || '')
  href = URL.parse(href)

  ['protocol', 'slashes', 'auth', 'host',
   'port', 'hostname', 'pathname', 'path',
  ].forEach (f) ->
    href[f] = origin[f] unless href[f]?

  unless (href.pathname.charAt 0) == '/'
    href.path = href.pathname =
      (path.join (path.dirname origin.pathname), href.pathname)

  URL.format(href)
