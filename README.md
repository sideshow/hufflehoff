[![Build Status](https://travis-ci.org/sideshow/hufflehoff.svg?branch=master)](https://travis-ci.org/sideshow/hufflehoff) [![Hex pm](http://img.shields.io/hexpm/v/hufflehoff.svg?style=flat)](https://hex.pm/packages/hufflehoff)

# Hufflehoff

A Huffman encoder/decoder for HTTP/2 header strings, implementing HPACK (RFC 7541 §5.2 and Appendix B).

This is an Elixir version of the Huffman code in [joedevivo/hpack](https://github.com/joedevivo/hpack).

`Hufflehoff.encode/1` and `Hufflehoff.decode/1` operate on raw octets. Header values are not required to be UTF-8, and bytes above 127 are preserved. `decode/1` raises `Hufflehoff.DecodeError` when padding is longer than 7 bits, padding is not a prefix of the EOS symbol, or the EOS symbol appears in the input.

## Installation

Add hufflehoff to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hufflehoff, "~> 0.0.1"}
  ]
end
```

## Usage

```elixir
iex> encoded = Hufflehoff.encode("www.example.com")
iex> Base.encode16(encoded, case: :lower)
"f1e3c2e5f23a6ba0ab90f4ff"
iex> Hufflehoff.decode(encoded)
"www.example.com"

iex> Hufflehoff.decode(Hufflehoff.encode(<<255, 0, 128>>))
<<255, 0, 128>>
```
