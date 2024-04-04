class ConversationsController < ApplicationController
  def show
    @conversation = Conversation.find_or_create_by(id: params[:id])
  end
end
