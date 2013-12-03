tumblr = require("tumblr.js")
Util = require("util")


module.exports = (robot) ->

  # Check TUMBLR keys are available
  unless process.env.TUMBLR_CONSUMER_KEY?
    robot.logger.warning 'TUMBLR_CONSUMER_KEY environment variable not set'
    process.exit 0
  unless process.env.TUMBLR_CONSUMER_SECRET?
    robot.logger.warning 'TUMBLR_CONSUMER_SECRET environment variable not set'
    process.exit 0
  unless process.env.TUMBLR_TOKEN?
    robot.logger.warning 'TUMBLR_TOKEN environment variable not set'
    process.exit 0
  unless process.env.TUMBLR_TOKEN_SECRET?
    robot.logger.warning 'TUMBLR_TOKEN_SECRET environment variable not set'
    process.exit 0
  unless process.env.TUMBLR_BLOG?
    robot.logger.warning 'TUMBLR_BLOG environment variable not set'
    process.exit 0

  blog = process.env.TUMBLR_BLOG

  client = tumblr.createClient(
    consumer_key: process.env.TUMBLR_CONSUMER_KEY
    consumer_secret: process.env.TUMBLR_CONSUMER_SECRET
    token: process.env.TUMBLR_TOKEN
    token_secret: process.env.TUMBLR_TOKEN_SECRET
  )


  robot.respond /yermomma$/i, (msg) ->
    msg.reply 'yermom'
    return
    client.link "furahasoftware.tumblr.com", url: "http://www.yahoo.com", (err, data) ->

      if err?
        console.log Util.inspect(err, false, 4)
        return
      console.log "----- posting URL"
      console.log Util.inspect(data, false, 4)

# Sample calls I used while learning how this works
#
#client.userInfo (err, data) ->
#  console.log "-----\nerr: #{err}"
#  console.log "-----\ndata: #{data}"
#  output = Util.inspect(data, false, 4)
#  console.log output
#  console.log "-----\n"
#  for blog in data.user.blogs
#    console.log Util.inspect(blog, false, 4)
#
#
#
#client.blogInfo "furahasoftware.tumblr.com", (err, data) ->
#  console.log "-----\nfurahasoftware BLOG NAME"
#  console.log Util.inspect(data.blog.name, false, 4)
#
#client.posts "furahasoftware.tumblr.com", (err, data) ->
#  console.log "-----\n POSTS"
#  for post in data.posts
#    console.log Util.inspect(post.url, false, 4)
#
#client.text "furahasoftware.tumblr.com", body: "this is text", (err, data) ->
#  if err?
#    console.log Util.inspect(err, false, 4)
#    return
#  console.log "----- Text posting DATA"
#  console.log Util.inspect(data, false, 4)
#
#client.link "furahasoftware.tumblr.com", url: "http://www.yahoo.com", (err, data) ->
#
#  if err?
#    console.log Util.inspect(err, false, 4)
#    return
#  console.log "----- posting URL"
#  console.log Util.inspect(data, false, 4)
    
