SAFARI_IPAD = 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25'
ICEWEASEL = 'Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20121202 Firefox/17.0 Iceweasel/17.0.1'


class LocalAgent

  request = (require 'request').defaults {
    headers:
      'User-Agent': ICEWEASEL
  }

  fetch: (url) -> request url


_ = require 'lodash'

{ DomCropper } = require 'wbt/cropper/dom'

module.exports = _.curry (name, parsers, url) -> {
  task: name
  agent: new LocalAgent
  target: url
  croppers: [DomCropper]
  buffer: 50
  dom: parsers
}
