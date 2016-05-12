'use strict'

should = require 'should'
UserToken = require '../src/userToken'

describe 'UserToken', ->
	context 'constructor', ->

		it 'should pass fsObj to @fs', ->
			expectedValue = { }
			target = new UserToken(expectedValue)
			should.strictEqual(target.fs, expectedValue)

		it 'should pass processObj to @process', ->
			expectedValue = { }
			target = new UserToken(null, expectedValue)
			should.strictEqual(target.process, expectedValue)

	context 'get', ->

		fsStub = class FSStub
			constructor: (existsResult, readResult) ->
				@existsResult = existsResult ? true
				@readResult = readResult ? "some token"
			existsSync: (path) -> return @existsResult
			readFileSync: (path, encoding) -> return @readResult

		processStub = class ProcessStub
			env:
				HOME: "/somepath"

		it 'should return some token', ->
			target = new UserToken(new FSStub(), new ProcessStub)
			should.equal(target.get(), "some token")

		it 'should throw an error if the ".vault-token" file doesn\'t exist', ->
			should.throws ->
				target = new UserToken(new FSStub(false), new ProcessStub())
				target.get()

