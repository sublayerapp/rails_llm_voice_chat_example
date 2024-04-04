import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    conversationId: Number
  }

  static targets = ["status"]
  mediaRecorder = null
  audioChunks = []

  clearSession() { window.location.href = '/' }

  connect() {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        this.mediaRecorder = new MediaRecorder(stream)
        this.mediaRecorder.ondataavailable = event => {
          this.audioChunks.push(event.data)
        }
        this.mediaRecorder.onstop = () => {
          const audioBlob = new Blob(this.audioChunks, { type: 'audio/wav' })
          this.uploadAudio(audioBlob)
          this.audioChunks = []
        }
      })
      .catch(error => console.error("Audio recording error:", error))
  }

  uploadAudio(audioBlob) {
    const formData = new FormData()
    formData.append('audio_data', audioBlob)
    formData.append('conversation_id', this.conversationIdValue)

    fetch('/conversation_messages', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        'Accept': 'application/json',
      },
    })
    .then(response => response.blob())
      .then(audioBlob => {
        const audioUrl = URL.createObjectURL(audioBlob)
        const audio = new Audio(audioUrl)
        audio.play()
        this.statusTarget.textContent = "Playing response..."
      })
    .catch(error => {
      console.error('Error:', error)
      this.statusTarget.textContent = "Upload failed."
    })
  }

  startRecording() {
    if (this.mediaRecorder) {
      this.mediaRecorder.start()
      this.statusTarget.textContent = "Recording..."
    }
  }

  stopRecording() {
    if (this.mediaRecorder) {
      this.mediaRecorder.stop()
      this.statusTarget.textContent = "Uploading..."
    }
  }
}

