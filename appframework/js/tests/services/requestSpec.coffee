###

ownCloud - App Framework

@author Bernhard Posselt
@copyright 2012 Bernhard Posselt nukeawhale@gmail.com

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
License as published by the Free Software Foundation; either
version 3 of the License, or any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU AFFERO GENERAL PUBLIC LICENSE for more details.

You should have received a copy of the GNU Affero General Public
License along with this library.  If not, see <http://www.gnu.org/licenses/>.

###

describe '_Request', ->

	beforeEach module 'OC'

	beforeEach inject (_Request, _Publisher) =>
		@router =
			generate: (route, values) ->
				return 'url'
			registerLoadedCallback: (callback) ->
				callback()
		@publisher = new _Publisher()
		@request = _Request
		


	it 'should not send requests if not initialized', =>
		http = jasmine.createSpy('http')
		@router.registerLoadedCallback = ->
		req = new @request(http, @publisher, @router)

		req.request('route')

		expect(http).not.toHaveBeenCalled()


	it 'should send requests if initialized', =>
		success =
			success: ->
				error: ->

		@router.registerLoadedCallback = (callback) ->
			@callback = callback
		@router.call = ->
			@callback()

		http = jasmine.createSpy('http').andReturn(success)

		config =
			route: 'route'
			params:
				test: 'test'
			data:
				abc: 'test'

		called =
			url: 'url'
			data: config.data

		req = new @request(http, @publisher, @router)
		req.request(config.route, config.params, config.data)

		@router.call()

		expect(http).toHaveBeenCalledWith(called)
		expect(http.callCount).toBe(1)


	it 'should should call router', =>
		success =
			success: ->
				error: ->

		http = jasmine.createSpy('http').andReturn(success)
		router =
			generate: jasmine.createSpy('router').andReturn('url')
			registerLoadedCallback: @router.registerLoadedCallback

		config =
			route: 'route'
			params:
				test: 'test'

		req = new @request(http, @publisher, router)
		req.request(config.route, config.params)

		expect(router.generate).toHaveBeenCalledWith(config.route, config.params)


	it 'should call callbacks', =>
		error =
			error: (callback) ->
				callback({})
		success =
			success: (callback) ->
				callback({})
				return error

		http = jasmine.createSpy('http').andReturn(success)
		onSuccess = jasmine.createSpy('onSucces')
		onFailure = jasmine.createSpy('onFailure')

		req = new @request(http, @publisher, @router)
		req.request(null, null, null, onSuccess, onFailure)

		expect(onSuccess).toHaveBeenCalled()
		expect(onFailure).toHaveBeenCalled()


	it 'should call publisher', =>
		fromServer =
			data:
				files: ['data']

		publisher =
			publishDataTo: jasmine.createSpy('publisher')

		error =
			error: (callback) ->
				callback({})
		success =
			success: (callback) ->
				callback(fromServer)
				return error

		http = jasmine.createSpy('http').andReturn(success)

		req = new @request(http, publisher, @router)
		req.request(null)

		expect(publisher.publishDataTo).toHaveBeenCalledWith(
			'files',
			fromServer.data.files
		)


	it 'should use default config', =>
		success =
			success: ->
				error: ->

		http = jasmine.createSpy('http').andReturn(success)
		req = new @request(http, @publisher, @router)

		defaultConfig =
			url: 'url'
			data:
				test: 2

		req.request('test', null, defaultConfig.data)

		expect(http).toHaveBeenCalledWith(defaultConfig)



	it 'should extend default config', =>
		success =
			success: ->
				error: ->

		http = jasmine.createSpy('http').andReturn(success)
		req = new @request(http, @publisher, @router)

		defaultConfig =
			url: 'wonderurl'
			data:
				test: 2

		req.request('test', null, defaultConfig.data, null, null,
			{url: defaultConfig.url})

		expect(http).toHaveBeenCalledWith(defaultConfig)


	it 'should have a post shortcut', =>
		success =
			success: ->
				error: ->

		http = jasmine.createSpy('http').andReturn(success)
		req = new @request(http, @publisher, @router)

		defaultConfig =
			url: 'wonderurl'
			method: 'POST'
			data:
				test: 2

		req.post('test', null, defaultConfig.data, null, null,
			{url: defaultConfig.url})

		expect(http).toHaveBeenCalledWith(defaultConfig)



	it 'should have a get shortcut', =>
		success =
			success: ->
				error: ->

		http = jasmine.createSpy('http').andReturn(success)
		req = new @request(http, @publisher, @router)

		defaultConfig =
			url: 'wonderurl'
			method: 'GET'
			data:
				test: 2

		req.get('test', null, defaultConfig.data, null, null,
			{url: defaultConfig.url})

		expect(http).toHaveBeenCalledWith(defaultConfig)