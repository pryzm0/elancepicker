bunyan = require 'bunyan'

module.exports = bunyan.createLogger {
  name: 'scrapejobs'
  serializers:
    res: bunyan.stdSerializers.res
  streams: [
    { level: 'trace', stream: process.stdout },
    # { level: 'info', path: '_robot.log' },
  ]
}
