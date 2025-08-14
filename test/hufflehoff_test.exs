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
    Enum.each(@examples, fn [plain, hex] ->
      assert Hufflehoff.encode(plain) == hex_to_bin(hex)
    end)
  end

  test "decoding" do
    Enum.each(@examples, fn [plain, hex] ->
      assert Hufflehoff.decode(hex_to_bin(hex)) == plain
    end)
  end

  def hex_to_bin(hex) do
    Base.decode16!(hex, case: :mixed)
  end

  test "decoding with valid padding" do
    # The huffman encoding of "abc" is <<28, 100>> which is <<0x1C, 0x64>>
    assert Hufflehoff.decode(<<28, 100>>) == "abc"
  end

  test "decoding with invalid padding" do
    # This binary string has an invalid padding sequence (the last 2 bits are "10" instead of "11")
    assert_raise RuntimeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(<<195, 138>>)
    end
  end
end
