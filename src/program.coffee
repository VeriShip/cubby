'use strict'

requestor = require './requestor'
userToken = require './userToken'
q = require 'q'

class Program
	constructor: (requestorObj, userTokenObj) ->
		@requestor = requestorObj ? new requestor()
		@userToken = userTokenObj ? new userToken()

	go: (ttl, policyCollection) =>
		
		@requestor.request(
			#	Create the temporary token with the
			#	given ttl value, only 2 uses, the default
			#	policy and the master token
			@requestor.createRequestOptions(
				"/v1/auth/token/create",
				"POST",
				null,
				@userToken.get()),
			{ ttl: @ttl ? "15m", num_uses: 2, policies: [ 'default' ] })

			#	The result should have the token at
			#	{ auth: { client_token: "<token>" } }
			.then (result) =>
				@tempToken = JSON.parse(result).auth.client_token
				q true

			#	Once we have the temp token, we create
			#	the permanent token, with default ttl
			#	and the supplied policies.
			.then =>
				@requestor.request(
					@requestor.createRequestOptions(
						"/v1/auth/token/create",
						"POST",
						null,
						@userToken.get()),
					{ policies: policyCollection })

			#	Once we have the two tokens we can 
			#	store the permanent token into a cubbyhole
			#	with the temporary token.
			.then (result) =>
				@requestor.request(
					@requestor.createRequestOptions(
						"/v1/cubbyhole/token",
						"POST",
						null,
						@tempToken),
					{ token: JSON.parse(result).auth.client_token })

			#	If we get this far, we return the temporary token
			#	for consumption.
			.then =>
				q @tempToken

module.exports = Program
