http = require 'http'
express = require 'express'

app = express()

app.use '/static', (express.static './bower_components')
app.use '/', (express.static './www')

app.get '/recent', (require './views/recent')

server = http.createServer app

server.listen process.env.PORT, ->
  console.log 'Listening on', process.env.PORT
