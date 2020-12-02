class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["950825dfd29f12a898a3e72cad04fd7b"]
    config.channel_token = ENV["S6as5OgJ6ObqI0Z2EoPIpkg3K+JBarTDE6qMihcVhcP3YnDBUBbESuA3U23l5Bn5BcGyBD61x7m9PIJD5UajP6U+j6RMW1k5aps+zWz05cnEmByaEKvI+yRQJM8UlRa/GNJZ5UQnhEAIxgC/A5zF2AdB04t89/1O/w1cDnyilFU="]

    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
        end
      end
    }

    head :ok
  end
end
