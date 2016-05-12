'use strict'

should = require 'should'
events = require 'events'
Requestor = require '../src/requestor'
queryString = require 'querystring'

describe 'Requestor', ->
	context '#constructor', ->

		it 'should pass qObj to @q', ->
			expectedValue = { }
			target = new Requestor(expectedValue)
			should.strictEqual(target.q, expectedValue)
		
		it 'should pass httpsObj to @https', ->
			expectedValue = { }
			target = new Requestor(null, expectedValue)
			should.strictEqual(target.https, expectedValue)

		it 'should pass processObj to @process', ->
			expectedValue = { }
			target = new Requestor(null, null, expectedValue)
			should.strictEqual(target.process, expectedValue)

	context '#request', ->

		class responseStub extends events
			constructor: ->
				@statusCode = 200

		class httpStub extends events
			constructor: ->
				@calls = [ ]
				@callbacks = [ ]
				@response = new responseStub()
				@payloads = [ ]
			request: (options, callback) =>
				@calls.push options
				@callbacks.push callback
				this
			end: =>
				for callback in @callbacks
					callback(@response)
			write: (payload) =>
				@payloads.push(payload)

		it 'should throw an error if we don\'t pass a javascript object to options', ->
			should.throws ->
				target = new Requestor()
				target.request(1)

		it 'should throw an error if we don\'t pass a javascript object to formData', ->
			should.throws ->
				target = new Requestor()
				target.request({ }, 1)

		it 'should return all compiled data on success.', (done) ->
			http = new httpStub()
			target = new Requestor(null, http, null)
			result = target.request({ })

			http.response.emit('data', 'some data')
			http.response.emit('end')

			result.done (actual) ->
				should.equal(actual, 'some data')
				done()

		it 'should return the error on failure.', (done) ->
			http = new httpStub()
			target = new Requestor(null, http, null)
			result = target.request({ })

			http.emit('error', 'some error')
			result.done { }, (error) ->
				should.equal error, 'some error'
				done()

		it 'should fail on status code less than 200 and greater than 299 (199)', (done) ->
			http = new httpStub()
			http.response.statusCode = 199
			
			target = new Requestor(null, http, null)
			result = target.request({ })

			http.response.emit('data', 'some data')
			http.response.emit('end')
			result.done { }, (error) ->
				should.equal error, 'some data'
				done()
		
		it 'should fail on status code less than 200 and greater than 299 (300)', (done) ->
			http = new httpStub()
			http.response.statusCode = 300
			
			target = new Requestor(null, http, null)
			result = target.request({ })

			http.response.emit('data', 'some data')
			http.response.emit('end')
			result.done { }, (error) ->
				should.equal error, 'some data'
				done()

		it 'should write the form object to the request.', (done) ->
			http = new httpStub()
			target = new Requestor(null, http, null)
			formObject = { test: "test" }
			result = target.request({ }, formObject)

			http.response.emit('data', 'some data')
			http.response.emit('end')

			result.done =>
				should.strictEqual(JSON.stringify(formObject), http.payloads[0])
				done()

	context "#createRequestOptions", ->

		class processStub
			constructor: (addr, verify) ->
				@env = { }
				@env["VAULT_ADDR"] = addr
				@env["VAULT_SKIP_VERIFY"] = verify

		it 'should throw an error if path is not a string', ->
			should.throws ->
				target = new Requestor(null, null, new processStub("a", true))
				target.createRequestOptions(1, "GET", null, '')

		it 'should throw an error if method is not GET|PUT|POST|LIST|DELETE', ->
			should.throws ->
				target = new Requestor(null, null, new processStub("a", true))
				target.createRequestOptions("a", "GETTER", null, '')

		it 'should throw an error if qsOptions is not a javascript object', ->
			should.throws ->
				target = new Requestor(null, null, new processStub("a", true))
				target.createRequestOptions("a", "GET", 1, '')

		it 'should throw an error if token is not a string', ->
			should.throws ->
				target = new Requestor(null, null, new processStub("a", true))
				target.createRequestOptions("a", "GET", { }, 1)

		it 'should throw an error if the VAULT_ADDR env variable is undefined', ->
			should.throws ->
				target = new Requestor(null, null, new processStub())
				target.createRequestOptions("a", "GET", { }, "a")

		it 'should throw an error if the VAULT_ADDR env variable is null', ->
			should.throws ->
				target = new Requestor(null, null, new processStub(null))
				target.createRequestOptions("a", "GET", { }, "a")

		it 'should throw an error if the VAULT_ADDR env variable is empty', ->
			should.throws ->
				target = new Requestor(null, null, new processStub(" "))
				target.createRequestOptions("a", "GET", { }, "a")

		it 'should return the appropriate object', ->

			path = "some/path"
			method = "LIST"
			qs =
				test: "dummy"
				value: 1
			token = "Some TOKEN"
			pStub = new processStub("https://dummy.com:1234", false)

			expected =
				hostname: "dummy.com"
				port: "1234"
				path: path + "?" + queryString.stringify(qs)
				method: method,
				rejectUnauthorized: true
				agent: false,
				headers:
					"X-Vault-Token": token

			target = new Requestor(null, null, pStub)
			should.deepEqual(target.createRequestOptions(path, method, qs, token), expected)


