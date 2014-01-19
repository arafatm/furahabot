# Description:
#   1. Display Premier League table
#   2. How is my team doing. Supported teams are:
#      manu, manc, arse, pool
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
#   furahabot  prem  - Get Premier League table 
#
# Credits:
#   @stephenyeargin 
#   https://github.com/websages/crunchy-ng/blob/master/scripts/preds.coffee

_ = require("underscore")
_s = require("underscore.string")
Select = require("soupselect").select
HTMLParser = require "htmlparser"
inspect = require('util').inspect

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

      console.log(res.statusCode)
      console.log(Object.prototype.toString.call(res.statusCode))

      result = parseHTML(body, "table#list tr.team")
      
      console.log(body.length)
      console.log(result.length)

      table = []
      for item in result
        team = item.children[0].children[0].children[0].data
        team = String(team + "               ").slice(0,7)
        pts  = String("00" + item.children[3].children[0].data).slice(-2)
        win  = String(" "+item.children[6].children[0].data).slice(-2)
        drw  = String(" "+item.children[8].children[0].data).slice(-2)
        los  = String(" "+item.children[10].children[0].data).slice(-2)
        gld  = String("  "+item.children[11].children[0].data).slice(-3)
        pld = Number(win) + Number(drw) + Number(los)
        pld = String("  " + pld).slice(-2)
        
        tit = "-----"
        if item.children[12].children[0].raw == "No"
          tit = "     "
        else
          tit  = String("     "+item.children[12].children[0].children[0].data).slice(-5)
          tit = "     " if tit == "  0.0"

        chl = "-----"
        if item.children[15].data == "td class=\"pr5\""
          chl = "     "
        else
          chl  = String("     "+item.children[15].children[0].children[0].data).slice(-5)
          chl = "     " if chl == "  0.0"

        row = pts + " " + gld + " " + team
        row = row + "  " + tit + "  " + chl
        row = row + "  " + pld + "  " + win + "  " + drw + "  " + los
        table.push(row)

      # sort and add header
      table = table.sort().reverse()
      table.splice(17,0,"---------------------------------------------------")
      table.splice(5,0,"---------------------------------------------------")
      table.splice(4,0,"---------------------------------------------------")
      table.unshift("---------------------------------------------------")
      table.unshift("Pt  GD            PL%    CL%   P   W   D   L")
      out.send "\n"+table.join("\n")


  

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
