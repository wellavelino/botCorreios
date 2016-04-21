#!/usr/bin/env ruby
require 'cuba'
require 'bundler/setup'
require 'cuba'
require 'multi_json'
require 'messenger/bot'

token = "CAAW5QUvL25YBABNYssrpwZB7JslZCOuh5Q9lgfq3J8Q649KjgBkpAHqNDBdZBCouCWXfwkeVZB0uxQiXlhMZCzC2rWiiZAMfi2AWOcAGW9iz7zv6DZBFO5zxOIZBa6Iu9pJbe01xtwLZBboPS0KmhycvyPtod1Oj6IsyzdEQZB93nYbgArANWHp6BtuDEH0bwLEewZD"
bot = Messenger::Bot::Client.new(token)

# deserialize JSON data from request body
def json_load(request_body)
  request_body.rewind
  body = request_body.read
  MultiJson.load body
end

Cuba.define do
  on get do
    on "messenger" do
      on param("hub.mode"), param("hub.challenge"), param("hub.verify_token") do |mode, challenge, token|
        if mode == "subscribe"
          # TODO: check the verify_token value that you inserted on the facebook developer page
          res.write challenge
        end
      end
    end
    on root do
      res.write "Hello world!"
    end
  end

  on post do
    puts "Got a post call #{res.to_json}"
    on "messenger" do
      data = json_load req.body
      # puts "#{data}"
      res.write "" #200
      callback = Messenger::Bot::Types::Callback.new(data)
      for e in callback.entry
        for mess in e.messaging
          if mess.message
            if mess.sender.id # We have someone to send the message to!
              options = {bot: bot, messaging: mess, token: token}
              bot.api.messages(recipient: {id: mess.sender.id}, message: { text: "Hello from a Bot!"})
            end
          else
            puts "Received Postback or delivery"
          end
        end
      end
    end
  end
end
