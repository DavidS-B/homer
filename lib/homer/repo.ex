defmodule Homer.Repo do
  use Ecto.Repo,
    otp_app: :homer,
    adapter: Ecto.Adapters.Postgres

    def init(_, config) do
      config =
        config
        |> Keyword.put(:username, System.get_env("PGUSER", "postgres"))
        |> Keyword.put(:password, System.get_env("PGPASSWORD", "postgres"))
        |> Keyword.put(:database, System.get_env("PGDATABASE", "postgres"))
        |> Keyword.put(:hostname, System.get_env("PGHOST", "localhost"))
        |> Keyword.update(:port, normalize_port(System.get_env("PGPORT")), &normalize_port/1)

      {:ok, config}
    end

    defp normalize_port(port) when is_binary(port), do: String.to_integer(port)
    defp normalize_port(port), do: port
end
