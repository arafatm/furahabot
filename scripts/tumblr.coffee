# Description:
#   Post stuff to tumblr
#
# Dependencies:
#   "tumblr.js": "*"
#   "util": "*"
#
# Configuration:
#   TUMBLR_CONSUMER_KEY - Sign up for OAuth on tumblr
#   TUMBLR_CONSUMER_SECRET - Sign up for OAuth on tumblr
#   TUMBLR_TOKEN - Sign up for OAuth on tumblr
#   TUMBLR_TOKEN_SECRET - Sign up for OAuth on tumblr
#   TUMBLR_BLOG - url for your blog where stuff should be posted
#
# Commands:
#
# Author:
#   Arafat Mohamed

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

  robot.hear /.*(https?:\/\/\S*)(.*)?/i, (msg) ->
    url   = msg.match[1]
    desc  = msg.match[2]
    if desc? 
      client.link blog, url: url, description: desc, (err, data) ->
        if err?
          msg.reply "Error posting: Try again :(\n#{Util.inspect(err, false, 4)}"
        else
          msg.reply "Posted http://#{blog}/post/#{data.id}"
    else
      client.link blog, url: url, (err, data) ->
        if err?
          msg.reply "Error posting: Try again :(\n#{Util.inspect(err, false, 4)}"
        else
          msg.reply "Posted http://#{blog}/post/#{data.id}"