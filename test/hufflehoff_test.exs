defmodule HufflehoffTest do
  use ExUnit.Case
  doctest Hufflehoff

  # examples from https://http2.github.io/http2-spec/compression.html#request.examples.with.huffman.coding
  @examples [
    ["www.example.com", "f1e3c2e5f23a6ba0ab90f4ff"],
    ["no-cache", "a8eb10649cbf"],
    ["Mon, 21 Oct 2013 20:13:21 GMT", "d07abe941054d444a8200595040b8166e082a62d1bff"]
  ]

  test "encoding" do
    Enum.each(@examples, fn x ->
      [plain, hex] = x
      assert Hufflehoff.encode(plain) == hex_to_bin(hex)
    end)
  end

  test "decoding" do
    Enum.each(@examples, fn x ->
      [plain, hex] = x
      assert Hufflehoff.decode(hex_to_bin(hex)) == plain
    end)
  end

  def hex_to_bin(hex) do
    Base.decode16!(hex, case: :mixed)
  end

end
