express = require "express"
cheerio = require "cheerio"
request = require "request"
async = require "async"
_ = require "underscore"
cache = require "memory-cache"

app = express()

app.use (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Methods", "GET"
  res.header "Access-Control-Allow-Headers", "Content-Type"
  next()

##
## For the most part, this just piggy-backs on the heroku HN API. We simply
## attach images to posts :)
##

app.get "/api/v1/news", (req, res) ->

  if cache.get "news"
    res.json cache.get "news"
  else

    request
      url: "http://node-hnapi.herokuapp.com/news"
      method: "get"
      timeout: 2000
    , (err, response, body) ->
      return res.send 500 if err

      async.map JSON.parse(body), (item, done) ->

        request
          url: item.url
          method: "get"
          timeout: 2000
        , (err, response, itemBody) ->

          # Happens rarely, usually because of a malformed url. Drop the item
          return done(null, null) if err

          $ = cheerio.load(itemBody)
          image = $('meta[property="og:image"]').attr "content"

          if image != undefined
            item = _.extend item, image: image

          done null, item

      , (err, items) ->

        # 5 minute cache
        cache.put "news", items, 5 * 60 * 1000

        res.json _.filter items, (i) -> i != null

app.listen 5656
