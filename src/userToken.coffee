fs = require 'fs'
path = require 'path'

class UserToken
	constructor: (fsObj, processObj) ->
		@fs = fsObj ? fs
		@process = processObj ? process
	get: ->
		tokenPath = path.join(@process.env["HOME"], '.vault-token')
		if not @fs.existsSync(tokenPath)
			throw new Error "You are not authenticated with vault.  (~/.vault-token does not exist)"

		@fs.readFileSync tokenPath, 'utf8'

module.exports = UserToken
