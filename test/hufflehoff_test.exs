defmodule HufflehoffTest do
  use ExUnit.Case
  doctest Hufflehoff

  # RFC 7541 Appendix C.4 and C.6 Huffman-encoded string literals.
  @rfc_examples [
    ["www.example.com", "f1e3c2e5f23a6ba0ab90f4ff"],
    ["no-cache", "a8eb10649cbf"],
    ["custom-key", "25a849e95ba97d7f"],
    ["custom-value", "25a849e95bb8e8b4bf"],
    ["302", "6402"],
    ["307", "640eff"],
    ["private", "aec3771a4b"],
    ["Mon, 21 Oct 2013 20:13:21 GMT", "d07abe941054d444a8200595040b8166e082a62d1bff"],
    ["Mon, 21 Oct 2013 20:13:22 GMT", "d07abe941054d444a8200595040b8166e084a62d1bff"],
    ["https://www.example.com", "9d29ad171863c78f0b97c8e9ae82ae43d3"],
    ["gzip", "9bd9ab"],
    [
      "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1",
      "94e7821dd7f2e6c7b335dfdfcd5b3960d5af27087f3672c1ab270fb5291f9587316065c003ed4ee5b1063d5007"
    ]
  ]

  test "encodes RFC 7541 examples" do
    Enum.each(@rfc_examples, fn [plain, hex] ->
      assert Hufflehoff.encode(plain) == hex_to_bin(hex)
    end)
  end

  test "decodes RFC 7541 examples" do
    Enum.each(@rfc_examples, fn [plain, hex] ->
      assert Hufflehoff.decode(hex_to_bin(hex)) == plain
    end)
  end

  test "round-trips the empty binary" do
    assert Hufflehoff.encode(<<>>) == <<>>
    assert Hufflehoff.decode(<<>>) == <<>>
  end

  test "round-trips every octet, including bytes above 127" do
    for byte <- 0..255 do
      bin = <<byte>>
      assert Hufflehoff.decode(Hufflehoff.encode(bin)) == bin
    end

    all = IO.iodata_to_binary(for byte <- 0..255, do: <<byte>>)
    assert Hufflehoff.decode(Hufflehoff.encode(all)) == all
  end

  test "decoding with valid padding" do
    # "abc" encodes to <<28, 100>> (0x1C64), which includes EOS padding.
    assert Hufflehoff.encode("abc") == <<28, 100>>
    assert Hufflehoff.decode(<<28, 100>>) == "abc"
  end

  test "decoding with invalid padding" do
    # Last bits are "10" rather than a prefix of EOS ("11...").
    assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(<<195, 138>>)
    end

    # "0" encodes as 0x07 (00000 111). Clearing the low bit breaks padding.
    assert Hufflehoff.encode("0") == <<0x07>>

    assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(<<0x06>>)
    end
  end

  test "rejects padding longer than 7 bits" do
    assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(<<0xFF>>)
    end

    # A valid encoding with an extra 0xFF octet is overlong padding.
    encoded = Hufflehoff.encode("www.example.com")

    assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(encoded <> <<0xFF>>)
    end
  end

  test "rejects the EOS symbol" do
    # 30 one-bits of EOS, padded to 32 bits.
    assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(<<0xFF, 0xFF, 0xFF, 0xFF>>)
    end

    # '0' is the 5-bit code 00000. Follow it with EOS (30 one-bits) and
    # 5 more one-bits so the buffer is octet-aligned.
    assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
      Hufflehoff.decode(<<0x07, 0xFF, 0xFF, 0xFF, 0xFF>>)
    end
  end

  test "requires binaries" do
    # apply/3 keeps this negative check out of the type checker, which
    # otherwise warns that a charlist is not a binary.
    assert_raise FunctionClauseError, fn -> apply(Hufflehoff, :encode, [~c"abc"]) end
    assert_raise FunctionClauseError, fn -> apply(Hufflehoff, :decode, [~c"abc"]) end
  end

  # Vectors from golang.org/x/net v0.59.0 http2/hpack (AppendHuffmanString /
  # HuffmanDecodeToString), cross-checked against Python hpack 4.2.0, which
  # ports nghttp2's Huffman decoder.
  test "matches reference HPACK implementations" do
    vectors =
      [__DIR__, "fixtures", "huffman_vectors.json"]
      |> Path.join()
      |> File.read!()
      |> JSON.decode!()

    Enum.each(vectors, fn vector ->
      encoded = Base.decode16!(vector["hex"], case: :mixed)
      plain = Base.decode16!(vector["plain"], case: :mixed)
      note = vector["note"]

      if vector["error"] do
        assert_raise Hufflehoff.DecodeError, "Invalid Huffman code sequence", fn ->
          Hufflehoff.decode(encoded)
        end
      else
        assert Hufflehoff.encode(plain) == encoded, "encode mismatch for #{note}"
        assert Hufflehoff.decode(encoded) == plain, "decode mismatch for #{note}"
      end
    end)
  end

  defp hex_to_bin(hex) do
    Base.decode16!(hex, case: :mixed)
  end
end
