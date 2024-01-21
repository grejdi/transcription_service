
# Transcription Service

Using whisper.cpp and llama.cpp w/ Mistral model to transcribe, clean, and summarize audio.

Note: This work has been done on M1 Mac Mini. It runs just OK. I can imagine a better computer would do much better.


## Getting Started

Some prerequisites:

1. Clone [whisper.cpp](https://github.com/ggerganov/whisper.cpp) into a local directory and follow the instructions in the [Quick Start](https://github.com/ggerganov/whisper.cpp?tab=readme-ov-file#quick-start) section.
2. Clone [llama.cpp](https://github.com/ggerganov/llama.cpp) into a local directory and follow the instructions in the [Mixtral pull request](https://github.com/ggerganov/llama.cpp/pull/4406)'s "Running the Instruct model" section.
  * Note: When cloning from HuggingFace, you will need [git LFS](https://git-lfs.com/) installed.
3. Install FFMpeg. [Homebrew Instructions](https://formulae.brew.sh/formula/ffmpeg)

Bring in executables and models into this repository:

1. Copy whisper.cpp files.
  * models/ggml-base.en.bin -> api/models/ggml-base.en.bin
  * main -> api/whisper
2. Copy llama.cpp files.
  * models/mixtral-instruct-7b/ggml-model-q4_0.gguf -> api/models/mixtral-instruct-7b/ggml-model-q4_0.gguf
  * ggml-metal.metal -> api/ggml-metal.metal
  * main -> api/mixtral

Set up API:

1. Install ASDF tooling.
```
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add python
asdf install
```
2. Standup database.
```
docker compose up
```
2. Build Elixir app and migrations.
```
mix deps.get
mix compile
mix ecto.migrate
```

## Running

1. Run Elixir app.
```
mix run --no-halt
```

## Using

```
curl -X POST -F "wav=@/Desktop/recording.webm" http://localhost:4000/upload
```
