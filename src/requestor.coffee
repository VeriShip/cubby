'use strict'

q = require 'q'
https = require 'https'
check = require 'check-types'
string = require 'string'
url = require 'url'
qs = require 'querystring'


class requestor
	constructor: (qObj, httpsObj, processObj) ->
		@q = qObj ? q
		@https = httpsObj ? https
		@process = processObj ? process

	request: (options, formData) =>

		if not check.object options
			throw new Error("You must pass a javascript object for options")
		if formData? and not check.object formData
			throw new Error("You must pass a javascript object for formData")
		
		deferred = q.defer()
		result = ""
		statusCode = 0

		req = @https.request options, (response) =>
			statusCode = response.statusCode
			response.on 'data', (d) =>
				result += d
			response.on 'end', (d) =>
				if statusCode < 200 or statusCode > 299
					deferred.reject(result)
				else
					deferred.resolve(result)

		req.on 'error', (err) =>
			deferred.reject(err)

		if formData?
			req.write(JSON.stringify(formData))
		req.end()

		deferred.promise

	createRequestOptions: (path, method, qsOptions, token) =>
		if not check.string path
			throw new Error "path must be a string"

		if not check.match method, "^(GET|POST|PUT|LIST|DELETE)$"
			throw new Error "method must be one of GET, POST, PUT, LIST, or DELETE"

		if qsOptions? and not check.object qsOptions
			throw new Error "qsOptions must be a javascript object"

		if not check.string token
			throw new Error "token must be a string"

		if not @process.env["VAULT_ADDR"]? or @process.env["VAULT_ADDR"].trim() == ""
			throw new Error("You must define the VAULT_ADDR environment variable in order for cubby to communicate with vault.")

		@process.env["VAULT_SKIP_VERIFY"] = @process.env["VAULT_SKIP_VERIFY"] ? false
		
		target = url.parse @process.env["VAULT_ADDR"]
		return {
			hostname: target.hostname,
			port: target.port,
			path: if qsOptions? then string(path).ensureRight('?').s + qs.stringify(qsOptions) else path,
			method: method,
			rejectUnauthorized: @process.env["VAULT_SKIP_VERIFY"] == false,
			agent: false,
			headers:
				"X-Vault-Token": token
		}

module.exports = requestor
