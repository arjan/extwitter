defmodule ExTwitter.API.Authorize do
  @moduledoc """
  Provides OAuth authorization API interfaces.
  """

  import ExTwitter.API.Base

  def request_token() do
    oauth = ExTwitter.Config.get_tuples |> verify_params
    consumer = {oauth[:consumer_key], oauth[:consumer_secret], :hmac_sha1}
    {:ok, {{_, 200, _}, _headers, body}} = ExTwitter.OAuth.request(:post, request_url("oauth/request_token"), [], consumer, [], [])
    Elixir.URI.decode_query(to_string body)
  end

  def authorize_url(oauth_token, redirect_url, options \\ %{}) do
    args = Map.merge(%{oauth_token: oauth_token, oauth_callback: redirect_url}, options)
    {:ok, request_url("oauth/authorize?" <> Elixir.URI.encode_query(args)) |> to_string}
  end
  
  def access_token(verifier, request_token, request_token_secret) do
    oauth = ExTwitter.Config.get_tuples |> verify_params
    consumer = {oauth[:consumer_key], oauth[:consumer_secret], :hmac_sha1}
    case ExTwitter.OAuth.request(:post, request_url("oauth/access_token"),
                                 [oauth_verifier: verifier],
                                 consumer, request_token, request_token_secret) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        Elixir.URI.decode_query(to_string body)
      {:ok, {{_, code, _}, _, _}} ->
        {:error, code}
    end
  end
  
end
