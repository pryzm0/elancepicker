SAFARI_IPAD = 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25'
ICEWEASEL = 'Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20121202 Firefox/17.0 Iceweasel/17.0.1'

random = (arr) -> arr[Math.floor arr.length * Math.random()]

request = require 'request'
touch = require 'touch'
FileCookieStore = require 'tough-cookie-filestore'


class LocalAgent

  COOKIE_JAR_FILE = '_cookiejar.json'

  touch.sync(COOKIE_JAR_FILE)

  _request = request.defaults {
    headers: {
      'User-Agent': ICEWEASEL
    }
    jar: (request.jar new FileCookieStore(COOKIE_JAR_FILE))
  }

  fetch: (url) -> _request(url)

  # log = require './logger'

  # fetch: (url) ->
  #   start = Date.now()

  #   _request(url).on 'response', (response) ->
  #     end = Date.now()

  #     log.trace {
  #       res: response
  #       headers: response.headers
  #       totalTime: (end - start)
  #     }, "fetch #{url}"


agent = new LocalAgent()

_ = require 'lodash'

{ DomCropper } = require 'wbt/cropper/dom'

module.exports = _.curry (name, parsers, url) -> {
  task: name
  agent: agent
  target: url
  croppers: [DomCropper]
  buffer: 50
  dom: parsers
}
