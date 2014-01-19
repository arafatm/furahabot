# Description:
#   How is my team doing.
#   Currently only supports ManU and Liverpool
#
# Dependencies:
#   "htmlparser": "1.7.6"
#   "soupselect": "0.2.0"
#   "underscore": "1.3.3"
#   "underscore.string": "2.3.0"
#
# Configuration:
#   None
#
# Commands:
#   furahabot <team> - Get results/odds for manu, pool, man, arse, chel

_ = require("underscore")
_s = require("underscore.string")
Select = require("soupselect").select
HTMLParser = require "htmlparser"
inspect = require('util').inspect
sys = require('sys')

out = null

module.exports = (robot) ->
  robot.respond /prem/i, (msg) ->
    out = msg
    getTable("http://www.sportsclubstats.com/England/Premier.html")
  robot.respond /manc/i, (msg) ->
    out = msg
    getSCSData("http://www.sportsclubstats.com/England/ManCity.html")
  robot.respond /chel/i, (msg) ->
    out = msg
    getSCSData("http://www.sportsclubstats.com/England/Chelsea.html")
  robot.respond /arse/i, (msg) ->
    out = msg
    getSCSData("http://www.sportsclubstats.com/England/Arsenal.html")
  robot.respond /pool/i, (msg) ->
    out = msg
    getSCSData("http://www.sportsclubstats.com/England/Liverpool.html")
  robot.respond /manu/i, (msg) ->
    out = msg
    getSCSData("http://www.sportsclubstats.com/England/ManUnited.html")
  

getTable = () ->
  out.http("http://www.sportsclubstats.com/England/Premier.html")
    .get() (err,res,body) ->

      # Catch errors
      if res.statusCode != 200
        out.send "Got a HTTP/" + res.statusCode
        out.send "Cannot get your standings right now."

      result = parseHTML(body, "table#list tr.team")
      
      table = "\nTeam           Pt    W   D   L\n"
      for item in result
        team = item.children[0].children[0].children[0].data
        team = String(team + "               ").slice(0,14)
        ply  = item.children[3].children[0].data + "  "
        win  = String(" "+item.children[6].children[0].data).slice(-2)
        drw  = String(" "+item.children[8].children[0].data).slice(-2)
        los  = String(" "+item.children[10].children[0].data).slice(-2)
        table = table + team + " " + ply + " " + win+"  "+drw+"  "+los+"\n"

      out.send table


  

getSCSData = (url) ->
  out.http(url)
    .get() (err,res,body) ->

      # Catch errors
      if res.statusCode != 200
        out.send "Got a HTTP/" + res.statusCode
        out.send "Cannot get your standings right now."
      else

      # Parse return
      result = parseHTML(body, "div.sub")

      # Date we want
      last_game = result[0].children[0].data
      standings = result[1].children[0].data

      # Sanitize standings
      standings = _s.unescapeHTML(standings)

      # Say it
      out.send last_game
      out.send standings.replace('&nbsp;',' ')


parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector


strCapitalize = (str) ->
  return str.charAt(0).toUpperCase() + str.substring(1);
