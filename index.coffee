http = require 'http'
express = require 'express'

app = express()

app.use '/static', (express.static './bower_components')
app.use '/', (express.static './www')

app.get '/recent', (require './views/recent')
app.get '/atom', (require './views/feed')

server = http.createServer app

server.listen (port = process.env.PORT ? 8080), ->
  console.log 'Listening on', port


# Run robot every 12 minutes.
setInterval (require './robot'), 12*60*1000
