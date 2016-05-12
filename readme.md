cubby
=====

Cubby is a command line tool used to help make interacting with [Hashicorp's Vault](https://github.com/hashicorp/vault) cubbyhold pattern much less painful.

Reference
---------

- [Vault](https://www.vaultproject.io/)
- [Cubbyhole](https://www.vaultproject.io/docs/secrets/cubbyhole/index.html)
- [Vault: Cubbyhole Authentication Principles](https://www.hashicorp.com/blog/vault-cubbyhole-principles.html)

How it Works
------------

1. You will need to be authenticated with vault.  I.E. you will need to have a token at `~/.vault-token`.
2. The `VAULT_ADDR` environment variable will need to be set to your instances of vault.

According to the cubbyhole pattern, we should not be passing around authentication tokens.  If we must (which we usually do with machines) we should only pass around tokens that have a very short ttl and a usage limit of 2.

Cubby helps facilitate this through Vaults http API.  It works in this order:

- Create the Temporary Token (The Temporary token assumes the default policy)
- Create the Permanent Token
- Store the Permanent Token in the cubbyhole/token secret backend with the Temporary token (1 use)
- Give the Temporary Token to STDOUT.

In the end, you'll get a temporary token that has 1 use left that you can pass to your army of machines.

Installation
------------

	npm install -g vs-cubby

Usage
-----
	cubby help

	[options]
	-t, --ttl:		The time to live for the temporary token. (Default 15m)
	-p, --policy:	A policy to associate with the permanent token. Can be used multiple times.

	cubby -t 5m -p engineers -p notadmins

Development
-----------

We like to use [coffeescript](http://coffeescript.org) and [grunt](http://gruntjs.com) here at VeriShip, so in order to build and run all tests, simply run:

	npm run dev

This will compile all source and test files then run all the tests.

Contributing
------------

If you encounter a bug or would like a feature that is not a part of Cubby yet, please fork and submit a pull request!

License
-------

MIT License

Copyright (c) 2016 VeriShip Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
