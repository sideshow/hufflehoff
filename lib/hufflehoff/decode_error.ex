defmodule Hufflehoff.DecodeError do
  @moduledoc """
  Raised when an HPACK Huffman string cannot be decoded.

  RFC 7541 §5.2 requires a decoding error when padding is longer than 7 bits,
  when padding is not the most significant bits of the EOS symbol, or when
  the EOS symbol appears in the encoded data.
  """

  defexception [:message]
end
