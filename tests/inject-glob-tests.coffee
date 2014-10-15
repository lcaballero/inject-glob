agg       = require("../src/inject-glob")
path      = require('path')


describe 'BurntSushi =>', ->

  describe 'find s5 =>', ->

    it 'should find all dependencies',  (done) ->
      opts =
        cwd           : 'files/sources/s5',
        globs         : [ '**/*.coffee', '**/*.json' ]
        interceptName : (name, injectName) ->
          switch (name)
            when 'config/default.json' then 'config'
            else injectName(name)

      agg(opts, (err, resolved) ->
        expect(err).to.not.exist
        expect(resolved).to.have.keys([
          'HomeController', 'cache', 'User', 'Database',
          'logger', 'app', 'server', 'config'
        ])
        expect(resolved.config.port).to.equal(4000)
        done()
      )

    it 'should aggregate onto model',  (done) ->
      opts =
        cwd           : 'files/sources/s5',
        globs         : [ '**/*.coffee', '**/*.json' ]
        aggregateOn   : (name) ->
          switch (path.dirname(name))
            when 'app/model' then { aggregateOn: 'model' }
            else undefined
        interceptName : (name, injectName) ->
          switch (name)
            when 'config/default.json' then 'config'
            else injectName(name)

      agg(opts, (err, resolved) ->
        expect(err).to.not.exist
        expect(resolved.model).to.have.keys(['User'])
        done()
      )


  describe 'find s4 =>', ->

    it 'should find all dependencies',  (done) ->
      opts =
        cwd   : 'files/sources/s4',
        globs : ['**/*.coffee']

      agg(opts, (err, resolved) ->
        expect(err).to.not.exist
        expect(resolved).to.have.keys(['HomeController', 'cache', 'User', 'Database'])
        done()
      )


  describe 'find s1 =>', ->

    it 'should find obj.coffee injected', (done) ->
      opts =
        cwd   : 'files/sources/s1'
        globs : ['**/*.coffee']

      agg(opts, (err, resolved) ->
        expect(err).to.not.exist

        expect(resolved.obj).to.exist

        { first, second } = resolved.obj
        expect(first).to.equal(1)
        expect(second).to.equal(2)
        done()
      )


  describe 'find s2', ->

    it 'should recurse into the subdirectory', (done) ->

      opts =
        cwd   : 'files/sources/s2'
        globs : ['**/*.coffee']

      agg(opts, (err, resolved) ->
        expect(err).to.not.exist
        expect(resolved.second).to.exist

        { third, fourth } = resolved.second
        expect(third).to.equal(3)
        expect(fourth).to.equal(4)
        done()
      )


  describe 'find s3', ->

    it 'should recurse into the subdirectory and find js as well as coffee', (done) ->

      opts =
        cwd   : 'files/sources/s3'
        globs : ['**/*.coffee', '**/*.js']

      agg(opts, (err, resolved) ->
        expect(err).to.not.exist
        expect(resolved.second, 'should have found second.coffee').to.exist
        expect(resolved.fourth, 'should have found fourth.js').to.exist

        { third, fourth } = resolved.second
        expect(third).to.equal(3)
        expect(fourth).to.equal(4)

        { fourth, five } = resolved.fourth
        expect(fourth).to.equal(4)
        expect(five).to.equal(5)
        done()
      )


  describe 'injectName =>', ->

    it 'should handle null', ->
      expect(-> agg.injectName(null)).to.not.throw(Error)

    it 'should handle undefined', ->
      expect(-> agg.injectName(undefined )).to.not.throw(Error)

    it 'should handle obj.coffee', ->
      s = agg.injectName('obj.coffee')
      expect(s).to.equal('obj')

    it 'shoul handle dir/obj.js', ->
      s = agg.injectName('dir/obj.js')
      expect(s).to.equal('obj')
