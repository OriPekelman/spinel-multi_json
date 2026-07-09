# multi_json — a Spinel-subset MIRROR of the multi_json gem.
#
# The require string mirrors the multi_json gem so `require "multi_json"`
# resolves here. This is a MIRROR, not a port: a narrowed contract
# reimplemented in the subset and oracled against the real gem. What is
# narrowed or excluded is in README.md's exclusion ledger.
#
# LOUD FAILURE (matz/spinel#1753 condition #3): define ONLY the ledgered
# surface here. Do not add a method_missing funnel — an out-of-ledger
# call must be an undefined method, which Spinel turns into a
# compile-time error, never a silent divergence.
require_relative "multi_json/core"

# module MultiJson is defined in multi_json/core.rb — re-exported by the
# require above. Keep the public entry surface here thin.
