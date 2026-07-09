# Oracle flow: drives the ledgered MultiJson surface with fixed inputs and
# prints deterministic output. The SAME flow, run against the compiled mirror,
# is snapshotted into test/smoke_test.rb.expected; oracle/run.sh runs it against
# the REAL multi_json gem and diffs — proving surface parity (matz/spinel#1753
# condition #2). Every line exercises one ledgered contract.
require "multi_json"

# dump: objects -> JSON string (json_gem contract)
puts MultiJson.dump({ "a" => 1, "b" => [1, 2, 3], "c" => nil, "d" => true })
puts MultiJson.dump([1, "two", 3.5, false])
puts MultiJson.dump("héllo €")
puts MultiJson.dump(:sym => "val")               # symbol keys stringify

# dump :pretty
puts MultiJson.dump({ "x" => { "y" => 1 } }, :pretty => true)

# load: JSON string -> objects (string keys)
p MultiJson.load('{"a":1,"b":[2,3]}')
p MultiJson.load('[]')
p MultiJson.load('"just a string"')
p MultiJson.load('42')
p MultiJson.load('  {"ws": true}  ')

# load :symbolize_keys (recursive)
p MultiJson.load('{"a":1,"nested":{"k":"v"}}', :symbolize_keys => true)

# aliases
puts MultiJson.encode({ "e" => 1 })
p MultiJson.decode('{"d":2}')

# round-trip
obj = { "list" => [1, 2, { "deep" => true }], "s" => "x" }
p MultiJson.load(MultiJson.dump(obj)) == obj

# error contract: invalid input -> MultiJson::ParseError (rescued by consumers)
begin
  MultiJson.load("{bad}")
  puts "no error"
rescue MultiJson::ParseError
  puts "ParseError raised"
end
# DecodeError is the same class
puts "DecodeError aliases ParseError: #{MultiJson::DecodeError == MultiJson::ParseError}"

# narrowed adapter identity
puts "default_adapter=#{MultiJson.default_adapter}"
