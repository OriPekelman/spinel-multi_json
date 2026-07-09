# Dual-runtime conformance: no snapshot is committed, so `spin test` diffs the
# compiled run against CRuby directly (the compiled-vs-CRuby leg of condition
# #2). Pure-Ruby logic only — no live service. One line per ledgered contract,
# printing a stable pass/fail token.
require_relative "../multi_json/core"

def check(name, cond)
  puts "#{name} #{cond ? 'ok' : 'FAIL'}"
end

# dump
check "dump_hash",   MultiJson.dump({ "a" => 1, "b" => [2, 3] }) == '{"a":1,"b":[2,3]}'
check "dump_array",  MultiJson.dump([1, "x", true, nil]) == '[1,"x",true,null]'
check "dump_symkey", MultiJson.dump(:k => "v") == '{"k":"v"}'
check "dump_pretty", MultiJson.dump({ "y" => 1 }, :pretty => true) == "{\n  \"y\": 1\n}"

# load
check "load_hash",   MultiJson.load('{"a":1,"b":[2,3]}') == { "a" => 1, "b" => [2, 3] }
check "load_scalar", MultiJson.load("42") == 42
check "load_string", MultiJson.load('"s"') == "s"
check "load_symbol", MultiJson.load('{"a":{"b":1}}', :symbolize_keys => true) == { a: { b: 1 } }

# aliases
check "encode_alias", MultiJson.encode({ "e" => 1 }) == '{"e":1}'
check "decode_alias", MultiJson.decode('{"d":2}') == { "d" => 2 }

# round-trip
obj = { "list" => [1, 2, { "deep" => true }], "s" => "x" }
check "roundtrip", MultiJson.load(MultiJson.dump(obj)) == obj

# error contract
err = begin
  MultiJson.load("{bad}"); nil
rescue MultiJson::ParseError
  :parse_error
end
check "parse_error", err == :parse_error
check "decode_error_alias", MultiJson::DecodeError == MultiJson::ParseError
check "load_error_alias",   MultiJson::LoadError == MultiJson::ParseError

# narrowed identity
check "default_adapter", MultiJson.default_adapter == :json_gem
check "adapter",         MultiJson.adapter == :json_gem
check "version",         MultiJson::VERSION == "0.1.0"
