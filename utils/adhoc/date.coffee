
require('sugar')

module.exports = (published) ->
  date = Date.create(published, '{dd}.{MM}.{yyyy}')

  if (isNaN date)
    unless (published.indexOf 'ago') == -1
      date = Date.create()
      if h = (/(\d+)h/i.exec published)
        date.rewind { hours: parseInt h[1] }
      if m = (/(\d+)m/i.exec published)
        date.rewind { minutes: parseInt m[1] }

  unless (isNaN date)
    return date
  return Date.create()
