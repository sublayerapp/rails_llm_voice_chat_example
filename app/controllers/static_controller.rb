class StaticController < ApplicationController
  def index
    # Create a new conversation and redirect to the show page for it
    conversation = Conversation.create
    redirect_to conversation_path(conversation)
  end
end
