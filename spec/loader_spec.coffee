Loader = require '../lib/loader'
ipso   = require '../lib/ipso'
{sep} = require 'path'

describe 'Loader', -> 

    it 'keeps original cwd', (done) -> 

        instance = Loader.create dir: 'DIR'
        Loader._test().dir.should.equal 'DIR'
        done()

    it 'can determine if a module starts with Uppercase', (done) -> 

        instance = Loader.create dir: 'DIR'
        Loader._test().upperCase('A').should.equal true
        Loader._test().upperCase('Z').should.equal true
        Loader._test().upperCase('a').should.equal false
        done()


    it 'attempts load from does.tagged (async injected) objects first', ipso (done) -> 

        instance = Loader.create dir: __dirname

        instance.loadModules ['tag1'], 

            #
            # mock result callback from does.get( query.tag )
            #

            get: (opts, callback) -> 
                opts.query.should.eql tag: 'tag1'
                callback null, object: this: 'thing'

            spectate: (opts, object) -> 

                opts.should.eql name: 'tag1', tagged: false 
                object.should.eql this: 'thing'
                done()


    it 'loads node_modules if starting with lowercase', ipso (done) -> 

        instance = Loader.create dir: 'DIR', modules: {}
        instance.loadModules ['http'], does = 

            get: (args...) -> args.pop()() # no tagged objects, empty callback
            spectate: (name, http) -> 

                http.should.equal require 'http'
                done()

    it 'loads specified modules by tag', ipso (done) -> 

        instance = Loader.create dir: __dirname, modules: Inspector: require: '../lib/inspector'
        instance.loadModules ['http', 'Inspector'], 

            get: (args...) -> args.pop()()

            #
            # stub does.spectate() to pass through directly
            #

            spectate: (name, m) -> m 

        .then ([http, Inspector]) -> 

            http.should.equal require 'http'
            Inspector.should.equal require '../lib/inspector'
            done()



    it 'recurses ./lib for underscored name', ipso (done) -> 

        instance = Loader.create dir: process.cwd() 
        
        Loader._test().recurse = (name, path) -> 
            name.should.equal 'module_name'
            path.should.equal process.cwd() + sep + 'lib'
            done()

        instance.loadModules ['ModuleName'], 
            get: (args...) -> args.pop()()
            spectate: (name, m) -> m


    it 'finds match', ipso (done) -> 

        instance = Loader.create dir: process.cwd() 
        instance.loadModules ['ModuleName'], 
            get: (args...) -> args.pop()()
            spectate: (name, m) -> m
        .then ([ModuleName]) ->

            ModuleName.test1().should.equal 1
            done()
