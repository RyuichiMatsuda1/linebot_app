class SynopsisController < ApplicationController
# app.rb
# require 'sinatra'
protect_from_forgery except: [:callback]
# skip_before_action :verify_authenticity_token
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    # config.channel_id = ENV["1655297930"]
    config.channel_secret = ENV["950825dfd29f12a898a3e72cad04fd7b"]
    config.channel_token = ENV["S6as5OgJ6ObqI0Z2EoPIpkg3K+JBarTDE6qMihcVhcP3YnDBUBbESuA3U23l5Bn5BcGyBD61x7m9PIJD5UajP6U+j6RMW1k5aps+zWz05cnEmByaEKvI+yRQJM8UlRa/GNJZ5UQnhEAIxgC/A5zF2AdB04t89/1O/w1cDnyilFU="]
  }
end

# post '/callback' do
def callback
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    head :bad_request
  end





  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  end

  # Don't forget to return a successful response
  head :ok
end
end