# Description:
#   Take notes of stuff did and doing.
#   Stolen from scrumnotes.coffee
#
# Dependencies:
#   None
#
# Commands:
#   note I did  ...      - capture 'did' notes for today
#   note I will ...      - capture 'will' notes for today
#   notes                - show my saved notes for today
#   notes all            - show all saves notes for today
#   notes yesterday      - show my saved notes from yesterday
#   notes 'MM-DD'        - show notes on '<current year>-MM-DD'
#   notes 'YYYY-MM-DD'   - show notes on 'YYYY-MM-DD'
#   notes '<nick>'       - show all notes for <nick>
#
# Author:
#   Arafat Mohamed

env = process.env
fs = require('fs')
Util = require "util"

module.exports = (robot) ->
  
  formatDate = (date) ->
    dd = date.getDate()
    mm = date.getMonth()+1
    yyyy = date.getFullYear()
    if (dd<10) 
      dd='0'+dd
    if (mm<10)
      mm='0'+mm
    return yyyy+'-'+mm+'-'+dd

  todayDate = ->
    date = new Date()
    return formatDate(date)

  yesterdayDate = ->
    date = new Date()
    date.setDate(date.getDate() - 1)
    return formatDate(date)

  robot.respond /note I (did|will) (.+)/i, (msg) ->
    user = msg.message.user.name
    key = msg.match[1].toLowerCase()
    note = msg.match[2]

    robot.brain.data.didNotes ?= {}
    notes = robot.brain.data.didNotes[todayDate()] ?= {}

    notes[user]       ?= {}
    notes[user][key]  ?= []
    notes[user][key].push(note)
    msg.reply "You #{key} #{note}"

    robot.brain.emit 'save'

  robot.respond /notes$/i, (msg) ->
    user = msg.message.user.name
    notes = robot.brain.data.didNotes?[todayDate()]?[user]

    if notes?
      if notes['did']?
        for note in notes['did']
          msg.send "#{user} did #{note}"
      if notes['will']?
        for note in notes['will']
          msg.send "#{user} will #{note}"
    else
      msg.send "No notes for you!"

  # TODO: why won't hubot respond without /i
  robot.respond /notes all$/i, (msg) ->
    input = msg.match[1] 

    allnotes = robot.brain.data.didNotes?[todayDate()]
    if allnotes?
      msg.send "Notes taken today:"
      for own user, notes of allnotes
        if notes['did']?
          for note in notes['did']
            msg.send "- #{user} did #{note}"
        if notes['will']?
          for note in notes['will']
            msg.send "- #{user} will #{note}"
    else 
      msg.send "No notes recorded today (#{todayDate()})"

  robot.respond /notes yesterday$/i, (msg) ->
    input = msg.match[1] 

    user = msg.message.user.name
    notes = robot.brain.data.didNotes?[yesterdayDate()]?[user]

    if notes?
      msg.reply("Notes for #{yesterdayDate()}\n")
      if notes['did']?
        for note in notes['did']
          msg.reply("#{user} did #{note}\n")
      if notes['will']?
        for note in notes['will']
          msg.reply("#{user} will #{note}\n")
    else
      msg.reply "No notes taken yesterday (#{yesterdayDate()})"

  robot.respond /notes (\d\d\d\d-)?(\d\d-\d\d)$/i, (msg) ->
    if msg.match[1]?
      input = "#{msg.match[1]}#{msg.match[2]}"
    else
      input = "#{new Date().getFullYear()}-#{msg.match[2]}"

    user = msg.message.user.name
    notes = robot.brain.data.didNotes?[input]?[user]

    if notes?
      msg.reply("Notes for #{input}\n")
      if notes['did']?
        for note in notes['did']
          msg.reply("- #{user} did #{note}\n")
      if notes['will']?
        for note in notes['will']
          msg.reply("- #{user} will #{note}\n")
    else
      msg.reply "No notes taken on #{input}"

  robot.respond /notes ([A-Za-z]\w*)$/i, (msg) ->
    user = msg.match[1]

    if user != "all" and user != "yesterday"

      notes = robot.brain.data.didNotes
      output = []
      if notes?
        for own day,daynote of notes
          if daynote[user]?['did']? or daynote[user]?['will']?
            output.push "  #{day}"
          if daynote[user]?['did']?
            for note in daynote[user]['did']
              output.push "      did #{note}"
          if daynote[user]?['will']?
            for note in daynote[user]['will']
              output.push "      will #{note}"
      if output.length?
        msg.reply "All notes for #{user}"
        msg.reply output.join('\n')

