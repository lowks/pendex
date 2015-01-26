Code.require_file "test_helper.exs", __DIR__

defmodule PendexTest do
  use ExUnit.Case, async: true

  test "prepare_request_body formats correctly" do
    assert Pendex.prepare_request_body("http://www.elixir-lang.org") == '{\'longUrl\': \'http://www.elixir-lang.org\'}'
  end

  test ".shrink_url returns correct response" do
    Pendex.start

    assert Pendex.shrink_url("http://www.elixir-lang.org") == { :ok, "http://goo.gl/Shz0u" }
    assert Pendex.shrink_url("http://www.elixir-lang.org", []) == { :ok, "http://goo.gl/Shz0u" }
  end


  ### With Options

  test "returns short_url with [:short_url] option" do
    Pendex.start

    assert Pendex.shrink_url("http://www.elixir-lang.org", [:short_url]) == "http://goo.gl/Shz0u"
  end

  test "returns short and long urls with [:urls] option" do
    Pendex.start

    expected_response_urls = { :ok, %{id: "http://goo.gl/Shz0u", longUrl: "http://www.elixir-lang.org/"} }
    assert Pendex.shrink_url("http://www.elixir-lang.org", [:urls]) == expected_response_urls
  end

  test "returns parsed JSON with [:json] option" do
    Pendex.start

    expected_response = {:ok,"{\"id\":\"http://goo.gl/Shz0u\",\"kind\":\"urlshortener#url\",\"longUrl\":\"http://www.elixir-lang.org/\"}"}
    assert Pendex.shrink_url("http://www.elixir-lang.org", [:json]) == expected_response
  end

  test "returns list with [:list] option" do
    Pendex.start

    expected_response = {:ok,%{id: "http://goo.gl/Shz0u", kind: "urlshortener#url", longUrl: "http://www.elixir-lang.org/"}}
    assert Pendex.shrink_url("http://www.elixir-lang.org", [:list]) == expected_response
  end

  test "returns default response with non-existant option" do
    Pendex.start

    assert Pendex.shrink_url("http://www.elixir-lang.org", [:non_existant]) == { :ok, "http://goo.gl/Shz0u" }
  end


  ### Exceptions

  test ".shrink_url returns a :bad_request with invalid or incomplete URL" do
      Pendex.start
      assert Pendex.shrink_url("http://") == { :error, :bad_request }
  end

  test "shrink_url raises Error for invalid argument" do
    assert_raise ArgumentError, fn ->
      Pendex.shrink_url(1234567890)
    end

    assert_raise ArgumentError, fn ->
      Pendex.shrink_url(666.666)
    end

    assert_raise ArgumentError, fn ->
      Pendex.shrink_url({})
    end

    assert_raise ArgumentError, fn ->
      Pendex.shrink_url(:atom)
    end
  end

  test "prepare_request_body raises Error for invalid argument" do
    assert_raise ArgumentError, fn ->
      Pendex.prepare_request_body(1234567890)
    end

    assert_raise ArgumentError, fn ->
      Pendex.prepare_request_body(666.666)
    end

    assert_raise ArgumentError, fn ->
      Pendex.prepare_request_body({})
    end

    assert_raise ArgumentError, fn ->
      Pendex.prepare_request_body(:atom)
    end
  end

  test "raises error with message for invalid arguments" do
    assert_raise ArgumentError, fn ->
      Pendex.prepare_request_body({})
    end

    assert_raise ArgumentError, fn ->
      Pendex.shrink_url({})
    end
  end
end

