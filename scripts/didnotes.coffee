# Description:
#   Take notes of stuff did and doing.
#   Stolen from scrumnotes.coffee
#
# Dependencies:
#   None
#
# Commands:
#   did: something
#   doing: something else
#   notes - show all saved notes
#
# Author:
#   Arafat Mohamed

env = process.env
fs = require('fs')
Util = require "util"

module.exports = (robot) ->
  
  getDate = ->
    today = new Date()
    dd = today.getDate()
    mm = today.getMonth()+1
    yyyy = today.getFullYear()
    if (dd<10) 
      dd='0'+dd
    if (mm<10)
      mm='0'+mm
    return yyyy+'-'+mm+'-'+dd

  robot.hear /^(did|doing): (.+)/i, (msg) ->
    today = getDate()
    user = msg.message.user.name
    key = msg.match[1]
    note = msg.match[2]

    robot.brain.data.didNotes ?= {}
    notes = robot.brain.data.didNotes[today] ?= {}

    notes[user]       ?= {}
    notes[user][key]  ?= []
    notes[user][key].push(note)
    msg.send "I heard #{user} #{key} #{note}"
    

    robot.brain.emit 'save'
    msg.send Util.inspect(robot.brain.data.didNotes, false, 4)


  robot.hear /^notes$/i, (msg) ->
    msg.send Util.inspect(robot.brain.data.didNotes, false, 4)


#  # rooms where hubot is hearing for notes
#  hearingRooms = {}
#  messageKeys = ['blocking', 'blocker', 'yesterday', 'today', 'tomorrow', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
#
#
#  listener = null
#
#  startHearing = ->  
#
#    if (listener)
#      return
#
#    listenersCount = robot.catchAll (msg) ->
#
#      if (!hearingRooms[msg.message.user.room])
#        return
#
#      today = getDate()
#      name = msg.message.user.name
#
#      robot.brain.data.scrumNotes ?= {};
#      notes = robot.brain.data.scrumNotes[today] ?= {}
#
#      notes._raw ?= [];
#      notes._raw.push([new Date().getTime(), name, msg.message.text])
#
#      keyValue = /^([^ :\n\r\t]+)[ :\n\t](.+)$/m.exec(msg.message.text)
#      if (keyValue)
#        notes[name] ?= {}
#        key = keyValue[1].toLowerCase()
#        if (key in messageKeys)
#          notes[name][key] ?= [];
#          notes[name][key].push(keyValue[2])
#
#    listener = robot.listeners[listenersCount - 1]
#
#  stopHearing = ->
#
#    if (!listener)
#      return
#
#    listenerIndex = -1
#    for list, i in robot.listeners
#      if list is listener
#        listenerIndex = i
#        break
#    if (listenerIndex >= 0)
#        setTimeout ->
#          robot.listeners.splice(i, 1)
#        , 0
#    listener = null
#
#  mkdir = (path, root) ->
#
#    dirs = path.split('/')
#    dir = dirs.shift()
#    root = (root||'')+dir+'/'
#
#    try
#      fs.mkdirSync(root)
#    catch e
#        # dir wasn't made, something went wrong
#        if (!fs.statSync(root).isDirectory())
#          throw new Error(e)
#
#    return !dirs.length || mkdir(dirs.join('/'), root)
#
#  robot.respond /(?:show )?scrum notes/i, (msg) ->
#
#    today = getDate()
#
#    notes = robot.brain.data.scrumNotes?[today]
#
#    if !notes
#      msg.reply('no notes so far')
#    else
#
#      # build a pretty version
#      response = []
#      for own user, userNotes of notes
#        if user != '_raw'
#          response.push(user, ':\n')
#          for key in messageKeys
#            if userNotes[key]
#              response.push('  ', key, ': ', userNotes[key].join(', '), '\n')
#
#      msg.reply(response.join(''))
#
#  robot.respond /take scrum notes/i, (msg) ->
#
#    startHearing()
#
#    hearingRooms[msg.message.user.room] = true
#
#    msg.reply('taking scrum notes, I hear you');
#
#  robot.respond /are you taking (scrum )?notes\?/i, (msg) ->
#
#    takingNotes = !!hearingRooms[msg.message.user.room]
#
#    msg.reply(if takingNotes then 'Yes, I\'m taking scrum notes' else 'No, I\'m not taking scrum notes')
#
#  robot.respond /stop taking (?:scrum )?notes/i, (msg) ->
#
#    delete hearingRooms[msg.message.user.room];
#
#    msg.reply("not taking scrum notes anymore");
#
#    today = getDate()
#    notes = robot.brain.data.scrumNotes?[today]
#
#    users = (user for user in Object.keys(notes) when user isnt '_raw')
#
#    count = if notes then users.length else 0
#
#    status = "I got no notes today"
#    if count > 0
#      status = ["I got notes from ", users.slice(0,Math.min(3, users.length - 1)).join(', '), " and ", if users.length > 3 then (users.length-3)+' more' else users[users.length-1]].join('')
#
#    msg.reply(status);
#
#    if (Object.keys(hearingRooms).length < 1)
#      stopHearing()
#
#    saveTo = process.env.HUBOT_SCRUMNOTES_PATH 
#
#    if (saveTo)
#      mkdir(saveTo + '/scrumnotes')
#      fs.writeFileSync(saveTo + '/scrumnotes/' + today + '.json', JSON.stringify(notes, null, 2))
#      msg.send('scrum notes saved at: /scrumnotes/' + today + '.json')
#
