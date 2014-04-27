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

    context 'loadModules()', -> 

        it 'loads node_modules if starting with lowercase', ipso (done) -> 

            instance = Loader.create dir: 'DIR', modules: {}
            instance.loadModules ['http'], does = 

                get: (args...) -> args.pop()() # no tagged objects, empty callback
                spectate: (opts, http) -> 

                    http.should.equal require 'http'
                    done()



        it 'loads node modules dasherized from lower camel case', ipso (done) -> 

            instance = Loader.create dir: 'DIR', modules: {}
            instance.loadModules ['testModule'], does = 

                get: (args...) -> args.pop()() # no tagged objects, empty callback
                spectate: (opts, http) -> 

                    http.should.equal require 'http'
                    done()

     

        it 'loads specified modules by tag', ipso (done) -> 

            instance = Loader.create dir: __dirname, modules: Saver: require: '../lib/saver'
            instance.loadModules ['http', 'Saver'], 

                get: (args...) -> args.pop()()

                #
                # stub does.spectate() to pass through directly
                #

                spectate: (opts, m) -> m 

            .then ([http, Saver]) -> 

                http.should.equal require 'http'
                Saver.should.equal require '../lib/saver'
                done()

        it 'recurses ./lib for underscored name', ipso (done) -> 

            instance = Loader.create dir: process.cwd() 
            
            Loader._test().recurse = (name, path) -> 
                name.should.equal 'module_name'
                path.should.equal process.cwd() + sep + 'lib'
                done()

            instance.loadModules ['ModuleName'], 
                get: (args...) -> args.pop()()
                spectate: (opts, m) -> m


        it 'finds match', ipso (done) -> 

            instance = Loader.create dir: process.cwd() 
            instance.loadModules ['ModuleName'], 
                get: (args...) -> args.pop()()
                spectate: (opts, m) -> m
            .then ([ModuleName]) ->

                ModuleName.test1().should.equal 1
                done()

    context 'loadModulesSync()', -> 

        it 'returns an array of loaded modules', ipso (done) -> 

            instance = Loader.create dir: process.cwd()
            [ModuleName, zlib, NonExistant] = instance.loadModulesSync ['ModuleName', 'zlib', 'NonExistant'], 
                spectateSync: (opts, m) -> m


            ModuleName.should.equal require '../lib/testing/recursor/module_name'
            zlib.should.equal       require 'zlib'

            NonExistant.$ipso.PENDING.should.equal true
            done()

        context 'it is used to inject into suites', ipso (os) -> 

            it 'has os', -> 

                os.should.equal require 'os'


