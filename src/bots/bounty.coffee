# Description:
#   Create a bounty
#
# Configuration:
#   HUBOT_TEAM_ADMIN - A comma separate list of user names
#
# Commands:
#   hubot create <bounty_name> bounty X coins - create bounty called <bounty_name> with X coins
#   hubot list bounties - list all existing bounties
#   hubot award <bounty_name> bounty to <username>  - award an existing bounty
#   hubot register <btc_address>


# Not displayed in help
#   hubot (<bounty_name>) bounty add me - add me to the bounty
#   hubot get balance - get your current balance
#   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
#   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
#   hubot (<bounty_name>) bounty remove (me|<user>) - remove me or <user> from bounty
#   hubot (<bounty_name>) bounty (empty|clear) - clear bounty list
#   hubot (delete|remove) <bounty_name> bounty - delete bounty called <bounty_name>
#   hubot (<bounty_name>) bounty -1 - remove me from the bounty
#   hubot (<bounty_name>) bounty count - list the current size of the bounty
#   hubot (<bounty_name>) bounty (list|show) - list the people in the bounty

{log, p, pjson} = require 'lightsaber'

swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
DCO = require '../models/dco'
{ values } = require 'lodash'

# Config          = require '../models/config'
# Account          = require '../models/account'
# Asset          = require '../models/asset'
# ResponseMessage = require './helpers/response_message'
# UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  # robot.brain.data.bounties or= {}
  Bounty.robot = robot

  robot.respond /award (.+) bounty to (.+) in (.+)$/i, (msg) ->
    [all, bountyName, awardee, dcoKey] = msg.match
    activeUser = robot.whose msg

    dco = DCO.find dcoKey

    usersRef = swarmbot.firebase().child('users')
    usersRef.orderByChild("slack_username").equalTo(awardee).on 'value', (snapshot) ->
        v = snapshot.val()
        vals = values v
        p "vals", vals
        awardeeAddress = vals[0].btc_address
        p "address", awardeeAddress

        # p "awardee", awardeeAddress values btc_address
        if(awardeeAddress)
          dco.awardBounty {bountyName, awardeeAddress}
          message = "Awarded bounty to #{awardee}"
          msg.send message
        else
          msg.send "User not yet registered"


  # robot.respond /award (.+) bounty to (.+)$/i, (msg) ->
  #   [all, bountyName, awardee] = msg.match
  #   activeUser = robot.whose msg
  #
  #   dco = DCO.find 'save-the-world'
  #
  #   usersRef = swarmbot.firebase().child('users')
  #   usersRef.orderByChild("slack_username").equalTo(awardee).on 'value', (snapshot) ->
  #       v = snapshot.val()
  #       vals = values v
  #       p "vals", vals[0]
  #       awardeeAddress = vals[0].btc_address
  #       p "address", awardeeAddress
  #
  #       # p "awardee", awardeeAddress values btc_address
  #       if(awardeeAddress)
  #         dco.awardBounty {bountyName, awardeeAddress}
  #         message = "Awarded bounty to #{awardee}"
  #         msg.send message
  #       else
  #         msg.send "User not yet registered"


  robot.respond /create (.+) bounty of (\d+) for (.+)$/i, (msg) ->
    msg.match.shift()
    [bountyName, amount, dcoKey] = msg.match

    DCO.createBountyFor {dcoKey, bountyName, amount}, (error, message) ->
      msg.send error or message

  robot.respond /register (.+)$/i, (msg) ->
    msg.match.shift()
    [btcAddress] = msg.match
    activeUser = robot.whose msg
    usersRef = swarmbot.firebase().child('users')
    usersRef.push( slack_username: activeUser, btc_address: btcAddress )
    msg.send "User registered"


  # robot.respond /create (\S*) bounty (\S*) coins?.*/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bountySize = msg.match[2]
  #   if bounty = Bounty.get bountyName
  #     message = ResponseMessage.bountyAlreadyExists bounty
  #   else
  #     bounty = Bounty.create bountyName, bountySize
  #     message = ResponseMessage.bountyCreated bounty
  #   msg.send message

  # robot.respond /(delete|remove) (\S*) bounty ?.*/i, (msg) ->
  #   bountyName = msg.match[2]
  #   if Config.isAdmin(msg.message.user.name)
  #     if bounty = Bounty.get bountyName
  #       bounty.destroy()
  #       message = ResponseMessage.bountyDeleted bounty
  #     else
  #       message = ResponseMessage.bountyNotFound bountyName
  #     msg.send message
  #   else
  #     msg.reply ResponseMessage.adminRequired()
  #
  # robot.respond /list bounties ?.*/i, (msg) ->
  #   bounties = Bounty.all()
  #   msg.send ResponseMessage.listBountys bounties
  #
  # robot.respond /(\S+) bounty add (\S+)$/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
  #   isMemberAdded = bounty.addMember user
  #   if isMemberAdded
  #     message = ResponseMessage.memberAddedToBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyAddedToBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty add me?.*/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name)
  #   isMemberAdded = bounty.addMember user
  #   if isMemberAdded
  #     message = ResponseMessage.memberAddedToBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyAddedToBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty remove (\S*) ?.*/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
  #   isMemberRemoved = bounty.removeMember user
  #   if isMemberRemoved
  #     message = ResponseMessage.memberRemovedFromBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyOutOfBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty -1/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name)
  #   isMemberRemoved = bounty.removeMember user
  #   if isMemberRemoved
  #     message = ResponseMessage.memberRemovedFromBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyOutOfBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty count$/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   message = if bounty then ResponseMessage.bountyCount(bounty) else ResponseMessage.bountyNotFound(bountyName)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty (list|show)$/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   message = if bounty then ResponseMessage.listBounty(bounty) else ResponseMessage.bountyNotFound(bountyName)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty (clear|empty)$/i, (msg) ->
  #   if Config.isAdmin(msg.message.user.name)
  #     bountyName = msg.match[1]
  #     if bounty = Bounty.getOrDefault bountyName
  #       bounty.clear()
  #       message = ResponseMessage.bountyCleared bounty
  #     else
  #       message = ResponseMessage.bountyNotFound bountyName
  #     msg.send message
  #   else
  #     msg.reply ResponseMessage.adminRequired()
  #
  # robot.respond /upgrade bounties$/i, (msg) ->
  #   bounties = {}
  #   for index, bounty of robot.brain.data.bounties
  #     if bounty instanceof Array
  #       bounties[index] = new Bounty index, bounty
  #     else
  #       bounties[index] = bounty
