defmodule Pendex do

  @shortdoc "Creates a short URL."
  @moduledoc """

  ### Example

  """

  def start do
    :application.start(:inets)
    :ssl.start
  end

  def stop do
    :application.stop(:inets)
    :ssl.stop
  end

  def main(args) do
    args |> parse_args |> do_cli
  end

  def parse_args(args) do
    options = OptionParser.parse(args, switches: [help: :boolean, url: :string, opt: :string], aliases: [h: :help])
    case options do
      { [ help: true ], _, _ }    -> :help
      # { _, [url, opt], _ }      -> [url, opt]
      {switches, _, _}            -> switches
      # { _, [url], _ }             -> [url]
      _                           -> :help
    end
  end

  def do_cli(:help) do
    IO.puts """
     Usage: 
      pendex [url] [format]

    """
    System.halt(0)
  end

  # def do_cli([url]) do
  #   case Pendex.shrink_url(url) do
  #     {ok, result} ->  IO.puts result
  #               _  ->  IO.puts "Could not shorten"
  #   end
  # end

  def do_cli(switches) when is_list(switches) do
    url = Keyword.get(switches, :url, nil)
    opt = Keyword.get(switches, :opt, nil)
  # def do_cli([url, opt]) do
    case {url, opt} do
      {nil, _} -> do_cli(:help)
      {_, nil} -> case Pendex.shrink_url(url) do
                    {ok, result} ->  IO.puts result
                    _  ->  IO.puts "Could not shorten"
                  end
      {_,_} -> case Pendex.shrink_url(url, [:opt]) do
                    {ok, result} ->  IO.puts result
                    _  ->  IO.puts "Could not shorten"
               end
    end
  end

  @doc "Prepares the body request for API"
  def prepare_request_body(url), do: Pendex.Request.prepare_request_body(url)

  @doc """
  Creates a short url from a long url using Google's URL Shortner API

  Args:
    * url - URL, binary string
  """
  def shrink_url(url), do: Pendex.Request.shrink_url(url, [])
  @doc """
  Args:
    * url - URL, binary string
  Options:
    * [:json] - Returns API response in JSON
    * [:list] - Returns API response in List type
    * [:urls] - Returns both short and long urls
    * [:short_url] - Returns the short url only
  """
  def shrink_url(url, opts), do: Pendex.Request.shrink_url(url, opts)

  defmodule Error do
    defexception [:message]
    def exception(message) do
      %Error{message: "#{inspect message.value} cannot be sent to Google Url Shortner API."}
    end
  end
end

defprotocol Pendex.Request do
  @only [BitString, List, Any]
  def prepare_request_body(url)
  def shrink_url(url, opts)
end

defimpl Pendex.Request, for: [Blank, Number, Float, Integer, Tuple, Atom] do
  def prepare_request_body(_), do: (raise Pendex.Error)
  def shrink_url(_, []),  do: (raise Pendex.Error)
end

defimpl Pendex.Request, for: BitString do
  def prepare_request_body(url) do
    String.to_char_list("{'longUrl': '" <> URI.decode(url) <>"'}")
  end

  def shrink_url(url), do: shrink_url(url, [])
  def shrink_url(url, opts) do
    case :httpc.request(:post, { 'https://www.googleapis.com/urlshortener/v1/url', [], 'application/json', prepare_request_body(url) },[], []) do
      { :ok, {{ _, 200, _}, _, body }} ->
        case opts do
          [:json] ->
            { :ok, res } = JSX.decode(:erlang.list_to_bitstring(body), [{ :labels, :atom }])
            JSX.encode(res)
          [:list] ->
            JSX.decode(:erlang.list_to_bitstring(body), [{ :labels, :atom }])
          [:urls] ->
            { :ok, res } = JSX.decode(:erlang.list_to_bitstring(body), [{ :labels, :atom }])
            { :ok, %{id: res[:id], longUrl: res[:longUrl]} }
          [:short_url] ->
            { :ok, res } = JSX.decode(:erlang.list_to_bitstring(body), [{ :labels, :atom }])
            res[:id]
          _ ->
            { :ok, res } = JSX.decode(:erlang.list_to_bitstring(body), [{ :labels, :atom }])
            { :ok, res[:id] }
        end
      { :ok, {{ _, 400, _ }, _, _ }} ->
        { :error, :bad_request }
    end
  end
end