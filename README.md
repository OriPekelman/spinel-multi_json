# multi_json (spinel-multi_json)

A Spinel-subset **mirror** of the [multi_json](https://rubygems.org/gems/multi_json) gem.
`require "multi_json"` resolves here; the surface mirrors the gem's contracts,
so code written against it resolves unchanged — within the exclusion ledger below.

```ruby
require "multi_json"

MultiJson.dump({ "a" => 1, "b" => [2, 3] })          # => '{"a":1,"b":[2,3]}'
MultiJson.dump({ "x" => 1 }, :pretty => true)         # => pretty JSON
MultiJson.load('{"a":1}')                             # => {"a" => 1}
MultiJson.load('{"a":1}', :symbolize_keys => true)    # => {a: 1}
MultiJson.encode(o) # alias for dump   MultiJson.decode(s) # alias for load
# invalid input raises MultiJson::ParseError (DecodeError / LoadError alias it)
```

## Status: verified — 17/17 compiled, ready to publish

At engine `git:65fb6d2d` the compiled mirror is **byte-identical to CRuby on all
17 conformance checks**, and `oracle/run.sh` matches the real multi_json gem 1/1.
Driving this mirror surfaced and got fixed three Spinel compiler issues:

- matz/spinel#1844 — `JSON.parse` silently emitting `0`.
- matz/spinel#1853 — `symbolize_names:` ignored + `rescue JSON::ParserError` miss.
- matz/spinel#2009 — root-anchored `rescue ::JSON::ParserError`, and a symbol-keyed
  hash serializing as `0` through a poly-slot (a trailing-keyword collapse).

All resolved. The mirror's `load`/`dump` (string- and symbol-keyed), `:pretty`,
`:symbolize_keys`, aliases, and `ParseError` wrapping all behave identically under
CRuby and Spinel. Ready to PR into [matz/spin-index](https://github.com/matz/spin-index).

## Exclusion ledger

This mirror claims the `multi_json` require string, which under
[matz/spinel#1753](https://github.com/matz/spinel/issues/1753) is honest only while:

1. **Divergences are ledgered** — the table below documents everything narrowed vs the real gem;
2. **The real gem is the oracle** — `oracle/run.sh` verifies the claimed surface differentially against a live multi_json (+ `spin test` diffs the compiled run against CRuby);
3. **Out-of-ledger surface fails loudly** — undefined methods are compile-time errors (no `method_missing` funnel), never silent divergence.

The real multi_json is a **backend selector** (autoloads oj / yajl / json_gem /
… and dispatches dynamically — the `const_missing` / `send` / `public_send`
surface the probe flagged, and why the gem's own source is `rejected`). The
mirror narrows this to **one fixed backend, the stdlib `json`** (the real gem's
own `default_adapter`). Seeded from the spinelgems probe of **multi_json 1.21.1**
(`rejected` @ `git:42adf886/aarch64-linux`); dispositions below are decided, not TODO.

| surface | disposition | note |
|---|---|---|
| backend selection (`use`, `adapter=`, `with_adapter`, `load_adapter`, oj/yajl/…) | **excluded** | One fixed backend (stdlib `json`). Calling these is undefined ⇒ compile-time error (loud). Root cause of the probe's `const_missing`/`send`/`public_send`. |
| `dump` / `encode` | **kept** | `JSON.generate`; `:pretty` ⇒ `JSON.pretty_generate`. |
| `load` / `decode` | **kept** | `JSON.parse`; `:symbolize_keys` ⇒ `symbolize_names`. Errors wrapped as `MultiJson::ParseError`. |
| `adapter` / `default_adapter` | **narrowed** | Return the fixed `:json_gem` identity (read-only); the mutating adapter API is excluded. |
| thread-safe adapter memoization (`mutex`) | **dropped** | Moot with a single fixed backend. |
| options beyond `:pretty` / `:symbolize_keys` | **excluded** | Not forwarded to the backend in v0.1. |
| `MultiJson::VERSION` | **narrowed** | The mirror's own `"0.1.0"`, not the gem's. |

## Architecture

- `multi_json.rb` — require root; claims the require string.
- `multi_json/core.rb` — the ledgered contract (`MultiJson`), explicit `def`s only, one backend.
- `test/multi_json_test.rb` — dual-runtime conformance (no snapshot; `spin test` diffs compiled-vs-CRuby).
- `oracle/` — replays the same flow through the **real** multi_json gem and diffs against the mirror-frozen snapshot.

## Developing

```sh
bin/verify          # spin test (compiled-vs-CRuby) + oracle/run.sh (vs the real gem)
sh oracle/run.sh    # real-gem parity leg (needs the multi_json gem installed)
ruby test/multi_json_test.rb   # conformance under CRuby
```
