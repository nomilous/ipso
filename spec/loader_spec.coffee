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


    it 'loads node_modules if starting with lowercase', ipso (done) -> 

        instance = Loader.create dir: 'DIR', modules: {}
        instance.loadModules ['http'], spectate: (http) -> 

            http.should.equal require 'http'
            done()

    it 'loads specified modules by tag', ipso (done) -> 

        instance = Loader.create dir: __dirname, modules: Inspector: require: '../lib/inspector'
        instance.loadModules( ['http', 'Inspector'], spectate:  (m) -> m )
        .then ([http, Inspector]) -> 

            http.should.equal require 'http'
            Inspector.should.equal require '../lib/inspector'
            done()

    it 'recurses ./lib for underscored name', (done) -> 

        instance = Loader.create dir: process.cwd() 
        
        Loader._test().recurse = (name, path) -> 
            name.should.equal 'module_name'
            path.should.equal process.cwd() + sep + 'lib'
            done()

        instance.loadModules( ['ModuleName'], spectate: (m) -> m )


    it 'finds match', (done) -> 

        instance = Loader.create dir: process.cwd() 
        instance.loadModules( ['ModuleName'], spectate: (m) -> m )
        .then ([ModuleName]) ->

            ModuleName.test1().should.equal 1
            done()
