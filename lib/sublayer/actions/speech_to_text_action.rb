require "tempfile"

module Sublayer
  module Actions
    class SpeechToTextAction < Base
      def initialize(audio_data)
        @audio_data = audio_data
      end

      def call
        tempfile = Tempfile.new(['audio', '.webm'], encoding: 'ascii-8bit')
        tempfile.write(@audio_data.read)
        tempfile.rewind

        text = HTTParty.post(
          "https://api.openai.com/v1/audio/transcriptions",
          headers: {
            "Authorization" => "Bearer #{ENV["OPENAI_API_KEY"]}",
            "Content-Type" => "multipart/form-data",
          },
          body: {
            file: tempfile,
            model: "whisper-1"
          })

        tempfile.close
        tempfile.unlink

        text["text"]
      end
    end
  end
end
