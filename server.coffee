express = require "express"
cheerio = require "cheerio"
request = require "request"
async = require "async"
_ = require "underscore"
cache = require "memory-cache"

process.setMaxListeners 0

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

    # Save the request so we can call setMaxListeners on it
    apiCall = request
      url: "https://news.ycombinator.com/"
      method: "get"
    , (err, response, body) ->
      return res.send 500 if err

      $ = cheerio.load body
      items = []

      content = $ "body > center > table > tr:nth-child(3) table tr"

      for row in [0...content.length] by 3
        rawTitle = content[row]
        rawDetails = $(content[row + 1]).find(".subtext")

        item =
          title: $(rawTitle).find(".title a").text()
          url: $(rawTitle).find(".title a").attr "href"

          domain: $(rawTitle).find(".title span.comhead").text()
          points: Number $(rawDetails).find("> span").text().split(" ")[0]
          comment_count: Number $(rawDetails).find("a:last-child").text().split(" ")[0]
          id: $(rawDetails).find("a:last-child").attr("href")

        # Process id
        if item.id
          item.id = Number item.id.split("id=")[1]
        else
          delete item.id

        # Clean up domain
        item.domain = "#{item.domain}".split("(").join("").split(")").join("").trim()

        items.push item

      async.mapLimit items, 9, (item, done) ->

        # Same as above
        imageRequest = request
          url: item.url
          method: "get"
          timeout: 2000
          maxRedirects: 10
        , (err, response, itemBody) ->

          # Happens rarely, usually because of a malformed url. Drop the item
          return done(null, null) if err

          $ = cheerio.load(itemBody)
          image = $('meta[property="og:image"]').attr "content"

          if image != undefined
            item = _.extend item, image: image

          done null, item

        imageRequest.setMaxListeners 0

      , (err, items) ->

        items = _.filter items, (i) -> i != null

        # 5 minute cache
        cache.put "news", items, 5 * 60 * 1000

        res.json items

    apiCall.setMaxListeners 0

app.listen 5656
