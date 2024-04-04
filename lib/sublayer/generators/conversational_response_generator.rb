module Sublayer
  module Generators
    class ConversationalResponseGenerator < Base
      llm_output_adapter type: :single_string,
        name: "response_text",
        description: "The response to the latest request from the user"

      def initialize(conversation_context:, latest_request:)
        @conversation_context = conversation_context
        @latest_request = latest_request
      end

      def generate
        super
      end

      def prompt
        <<-PROMPT
          #{@conversational_context}
          #{@latest_request}
        PROMPT
      end
    end
  end
end
