`#!/usr/bin/env node
`

program = new (require './program')()
commander = require 'commander'
q = require 'q'
policyCollection = [ ]

collect = (val, varCollection) ->
	varCollection.push(val)
	varCollection

commander.version(process.env.npm_package_version)
	.description("Creates a token with the given policies, a temporary token with only the default policy and two uses, then uses the temporary token to store the more permanent token in cubbyhole/token")
	.usage('[options]')
	.option('-p, --policy [policy]', 'A policy to apply to the permanent token.  You can use this flag multiple times.', collect, policyCollection)
	.option('-t,--ttl [ttl]', 'The time to live for the temporary token.')
	.parse(process.argv)

success = (data) ->
	console.log(data)
	process.exit(0)

failure = (err) ->
	console.log(err)
	process.exit(1)

program.go commander.ttl ? "15m", policyCollection
	.done success, failure

