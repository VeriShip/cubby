'use strict'

should = require 'should'
events = require 'events'
Program = require '../src/program'
queryString = require 'querystring'
q = require 'q'

describe 'Program', ->
	context '#constructor', ->
		
		it 'should pass requestorObj to @requestor', ->
			expectedValue = { }
			target = new Program(expectedValue)
			should.strictEqual(target.requestor, expectedValue)
		
		it 'should pass userTokenObj to @userToken', ->
			expectedValue = { }
			target = new Program({ }, expectedValue)
			should.strictEqual(target.userToken, expectedValue)

	context '#go', ->

		it 'should throw an error if we pass undefined in for path', ->
			should.throws ->
				target = new Program()
				target.request()

		it 'should throw an error if we pass null in for path', ->
			should.throws ->
				target = new Program()
				target.request(null)

		it 'should throw an error if we pass something other than a string for  path', ->
			should.throws ->
				target = new Program()
				target.request(1)
		
		it 'should throw an error if we pass undefined in for ttl', ->
			should.throws ->
				target = new Program()
				target.request("a")

		it 'should throw an error if we pass null in for ttl', ->
			should.throws ->
				target = new Program()
				target.request("a", null)

		it 'should throw an error if we pass something other than a string for  ttl', ->
			should.throws ->
				target = new Program()
				target.request("a", 1)
		
		it 'should throw an error if we pass undefined in for policyCollection', ->
			should.throws ->
				target = new Program()
				target.request("a", "a")

		it 'should throw an error if we pass null in for policyCollection', ->
			should.throws ->
				target = new Program()
				target.request("a", "a", null)

		it 'should throw an error if we pass in something other than an array', ->
			should.throws ->
				target = new Program()
				target.request("a", "a", 1)

		it 'should throw an error if we pass in an array with values that are not strings', ->
			should.throws ->
				target = new Program()
				target.request("a", "a", [ 'a', 1 ])


		#it 'should return temporary token', (done) ->
		#	class RequestorStub
		#		constructor: (requestQueue, optionsQueue) ->
		#			@requestQueue = requestQueue
		#			@optionsQueue = optionsQueue

		#		request: =>
		#			q @requestQueue.pop()

		#		createRequestOptions: =>
		#			@optionsQueue.pop()

		#	optionsQueue = [
		#		{ }, { }, { }
		#	]

		#	requestQueue = [
		#		JSON.stringify({ }),
		#		JSON.stringify({ auth: { client_token: "permToken" } }),
		#		JSON.stringify({ auth: { client_token: "TempToken" } })
		#	]

		#	requestorStub = new RequestorStub(requestQueue, optionsQueue)

		#	target = new Program(requestorStub)
		#	target.go("a", "b", [ "a" ]).done (success) ->
		#		should.equal("TempToken", success)
		#		done()
