defmodule Api.Router do
  use Plug.Router

  alias Api.Repo
  alias Api.Request
  alias Api.Workers.Transcribe

  require Oban

  @template_dir "lib/api/templates"

  plug(Plug.Parsers,
    pass: ["text/*"],
    parsers: [:multipart, :json],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    render(conn, "index.html")
  end

  post "/upload" do
    wav_file = wav_file(conn.body_params)

    {status, response_body} = move_wav_file(wav_file)

    render_json(%{conn | status: status}, response_body)
  end

  get "/_health" do
    send_resp(conn, 200, "Healthy!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  # private
  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end

  defp render_json(%{status: status} = conn, data) do
    body = Jason.encode!(data)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status || 200, body)
  end

  defp wav_file(%{"wav" => %Plug.Upload{} = file}), do: file
  defp wav_file(_no_wav_file), do: nil

  defp move_wav_file(%Plug.Upload{} = file) do
    request_rec = %Request{
      status: "started",
      uuid: Ecto.UUID.generate()
    }
    request_info = %{request: request_rec.uuid}
    Repo.insert!(request_rec)

    # copy to a more permanent place
    File.cp(file.path, "/tmp/#{request_rec.uuid}.wav")

    # start oban job
    Oban.insert(Transcribe.new(request_info))

    {200, request_info}
  end

  defp move_wav_file(nil) do
    {400, %{error: "No wav file uploaded."}}
  end
end
