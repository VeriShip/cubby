fs = require 'fs'
path = require 'path'
os = require 'os'

class UserToken
	constructor: (fsObj, osObj) ->
		@fs = fsObj ? fs
		@os = osObj ? os
	get: ->
		tokenPath = path.join(@os.homedir(), '.vault-token')
		if not @fs.existsSync(tokenPath)
			throw new Error "You are not authenticated with vault.  (~/.vault-token does not exist)"

		@fs.readFileSync tokenPath, 'utf8'

module.exports = UserToken
