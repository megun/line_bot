class LineBotsController < ApplicationController
  require 'line/bot'

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          docomoru_res = docomo_clients(event.message['text'], t: 20)
          message = {
            type: 'text',
            text: docomoru_res.body["utt"]
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    render status: 200, json: { message: 'OK' }
  end

  private
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

    def docomo_clients(sendmsg, params={})
      client = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
      client.create_dialogue(sendmsg, params)
    end
end
