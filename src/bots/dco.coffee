# Description:
#   Create a DCO (from Slack or any Hubut supported channel!)
#
# Dependencies:
#   None
#
# Commands:
#   hubot list dcos - list all existing DCOs (limit 10)
#   hubot list dcos XYZ - list all existing DCOs that match XYZ
#   hubot select <dco_name> (you must be the creator)
#   hubot create <dco_name> dco
#   hubot set statement of intent <statement_of_intent>
#   hubot issue X of asset - issue X of associated asset. You will need to pay Bitcoins to this address.
#   hubot send asset to <user_name>
#   hubot create constitution (creates a fork of the Citizen Code constitution)
#   hubot file dco (dynamically creates an LLC)
#   hubot open for membership for $XYZ - allow users to join membership in your DCO for a set price in USD
#   hubot open for membership for xyzBTC - allow users to join membership in your DCO) for a set price in BTC
#   hubot join <dco_name> - join a DCO, usually by agreeing to the statement of intent and paying a membership fee
#   hubot rate <dco_name> - Tells you how much the DCOs assets are trading at on any given day.
#
# Author:
#   fractastical

Config          = require '../models/config'
Account          = require '../models/account'
Asset          = require '../models/asset'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'


module.exports = (robot) ->
  robot.brain.data.bounties or= {}
  Asset.robot = Bounty.robot = Account.robot = robot

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

  ##
  ## hubot create <bounty_name> bounty - create bounty called <bounty_name>
  ##
  robot.respond /issue asset?.*/i, (msg) ->

        Colu = require('colu')
        settings =
          network: 'testnet'
          privateSeed: 'abcd4986fdac1b3a710892ef6eaa708d619d67100d0514ab996582966f927982'
        colu = new Colu(settings)
        asset =
          amount: 500
          metadata:
            'assetName': 'Chicago: The Musical'
            'issuer': 'AMBASSADOR THEATRE, 219 West 49th Street, New York, NY 10019'
            'description': 'Tickets to the show on 1/1/2016 at 8 PM'
        colu.on 'connect', ->
          colu.issueAsset asset, (err, body) ->
            if err
              return console.error(err)
            console.log 'Body: ', body
            return
          return
        colu.init()


    $robot.brain.data.bounties = bounties
    msg.send ResponseMessage.listBountys Bounty.all()
