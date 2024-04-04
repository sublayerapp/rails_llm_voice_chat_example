require "tempfile"
require "pry"
require "json"

class ConversationMessagesController < ApplicationController
  def clear
    session[:conversation_context] = nil

    render json: {message: "Conversation context cleared"}
  end

  def create
    conversation = Conversation.find(params[:conversation_id])

    # Convert conversational context to an easy to use format
    conversational_context = conversation.messages.map { |message| {role: message.role, content: message.content} }

    # Convert audio data to text
    text = Sublayer::Actions::SpeechToTextAction.new(params[:audio_data]).call

    # Generate conversational response
    output_text = Sublayer::Generators::ConversationalResponseGenerator.new(conversation_context: conversational_context, latest_request: text).generate

    # Convert text to audio data
    speech = Sublayer::Actions::TextToSpeechAction.new(output_text).call

    # Store conversation context for next message
    conversation.messages << Message.new(conversation: conversation, role: "user", content: text)
    conversation.messages << Message.new(conversation: conversation, role: "assistant", content: output_text)

    send_data speech, type: "audio/wav", disposition: "inline"
  end
end
