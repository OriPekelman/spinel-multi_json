# Core contract for the multi_json mirror.
#
# The real multi_json is a *backend selector*: it autoloads one of several JSON
# engines (oj, yajl, json_gem, …) and dispatches to it dynamically (const_missing
# + send/public_send — the surface the spinelgems probe flagged, and the reason
# the gem's own source is `rejected` under the subset). A mirror does not need
# selection: under Spinel there is exactly one backend, the bundled stdlib `json`
# (the real gem's own default adapter is `json_gem`, i.e. stdlib JSON). So the
# mirror *is* the json_gem adapter, with the selection machinery excluded. See
# README.md's exclusion ledger.
require "json"

module MultiJson
  VERSION = "0.1.0"

  # Invalid input raises ParseError; DecodeError/LoadError alias it, matching the
  # real gem's hierarchy so `rescue MultiJson::ParseError` (or DecodeError) works.
  class ParseError < StandardError; end
  DecodeError = ParseError
  LoadError = ParseError

  module_function

  # dump(object, options={}) -> String. Honors :pretty (=> JSON.pretty_generate),
  # matching the json_gem adapter. `encode` is the documented alias.
  def dump(object, options = {})
    if options[:pretty]
      ::JSON.pretty_generate(object)
    else
      ::JSON.generate(object)
    end
  end

  def encode(object, options = {})
    dump(object, options)
  end

  # load(string, options={}) -> parsed value. Honors :symbolize_keys
  # (=> JSON.parse symbolize_names). Wraps the backend's parse error in
  # MultiJson::ParseError. `decode` is the documented alias.
  def load(string, options = {})
    ::JSON.parse(string, symbolize_names: options[:symbolize_keys] ? true : false)
  rescue ::JSON::ParserError => e
    raise ParseError, e.message
  end

  def decode(string, options = {})
    load(string, options)
  end

  # Narrowed adapter surface: one fixed backend. `adapter`/`default_adapter`
  # answer the identity so introspecting consumers don't break; the *mutating*
  # surface (use/adapter=/with_adapter) is excluded — see the ledger.
  def default_adapter
    :json_gem
  end

  def adapter
    :json_gem
  end
end
