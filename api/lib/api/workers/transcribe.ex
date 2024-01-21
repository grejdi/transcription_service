defmodule Api.Workers.Transcribe do
  use Oban.Worker,
    queue: :transcribe,
    max_attempts: 1

  @impl true
  def perform(%{args: %{"request" => request_uuid}} = _job) do
    # convert audio file into somethin ingestible by whisper.cpp
    {output, status} =
      System.cmd("ffmpeg", [
        "-i", "/tmp/#{request_uuid}.wav",
        "-ar", "16000",
        "-y", # overwrite
        "/tmp/#{request_uuid}.ffmpeg.wav"
      ])

    # generate transcription
    whisper_cmd = File.cwd! |> Path.join("whisper")
    {output, status} =
      System.cmd(whisper_cmd, [
        "--output-txt",
        "--model", "./models/ggml-base.en.bin",
        "--file", "/tmp/#{request_uuid}.ffmpeg.wav"
      ])

    # get transcription text
    {:ok, transcription_text} = File.read("/tmp/#{request_uuid}.ffmpeg.wav.txt")

    # run mixtral instruct with prompt to clean up transcription
    mixtral_cmd = File.cwd! |> Path.join("mixtral")
    {output, status} =
      System.cmd(mixtral_cmd, [
        "-m", "./models/mixtral-instruct-7b/ggml-model-q4_0.gguf",
        "-p", """
[INST]
Please review and correct any inaccuracies in the following transcription, ensuring that it accurately reflects the spoken words, grammar, and punctuation of the original audio. Pay attention to homophones, proper nouns, and technical terms specific to the subject matter.
---
#{transcription_text}
---
[/INST]
"""
      ])

    # todo: run mixtral instruct with prompt to summarize cleaned up transcription

    :ok
  end
end
