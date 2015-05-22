Feed = require 'feed'

module.exports = (req, res) ->
  (require '../storage').then (storage) ->
    storage.getPage(0, 15).then (data) ->
      feed = new Feed {
        title: 'Web Scraping Jobs'
        description: 'Latest web scraping job offers scraped from major freelance sites'
        link: 'http://elancepicker.herokuapp.com'
        copyright: 'All rights reserved, 2015'
        author: {
          name: 'Konstantin Kopkov'
          email: 'pryzm0@gmail.com'
          link: 'http://github.com/pryzm0/'
        }
      }

      data.list.forEach (entry) ->
        feed.addItem {
          title: entry.title
          link: entry.target
          description: """
            <strong>Published:</strong> #{entry.published}<br/>
            <strong>Price:</strong> #{entry.price || '--/--'}
            <br/><br/>
            #{entry.description.replace('\n', '<br/>')}
            </pre>
          """
          date: entry.discovered
        }

      res.set 'Content-Type', 'application/atom+xml'
      res.send (feed.render 'atom-1.0')
