require "multi_json"

# Basic usage — mirrors the real multi_json gem's contracts.
puts MultiJson.dump({ "name" => "spin", "deps" => ["json"], "ok" => true })
#=> {"name":"spin","deps":["json"],"ok":true}

parsed = MultiJson.load('{"name":"spin","n":2}')
puts parsed["name"]            #=> spin
puts parsed["n"]               #=> 2

puts MultiJson.dump({ "nested" => { "k" => 1 } }, :pretty => true)

begin
  MultiJson.load("{not json}")
rescue MultiJson::ParseError => e
  puts "rejected: #{e.class}"  #=> rejected: MultiJson::ParseError
end
