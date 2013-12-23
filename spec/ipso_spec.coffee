ipso = require '../lib/ipso'
should  = require 'should'
{deferred, util} = require 'also'
Loader = require '../lib/loader'
does = require 'does'



describe 'ipso', -> 

    before -> 

        resolver = => @resolve

        @fakeit = (title, fn) => 
            @test = timer: _onTimeout: ->
            fn.call @, resolver()


        @resolvingPromise = deferred (action) -> 
            action.resolve 'RESULT'

    beforeEach -> @RESULT = undefined


    it 'works normally', -> 

        #console.log 'in works normally'.bold
        true.should.equal true

    # it 'still works normally', ipso -> 

    #     console.log 'in still works normally'.bold
    #     true.should.equal false


    context 'it warns on injecting done into context', ipso (done) ->


    context 'for mocha tests', ->


        it 'goes in front of a test function like this:', ipso -> 

            # console.log @resolvingPromise


        context 'injection for synchronous tests', -> 

            it 'returns a function with done as the only argument if no "done"', (done) -> 

                #
                # injection is asynchronous even when mocha test is not
                #

                fn = ipso (zlib, net) -> 
                args = util.argsOf fn
                args.should.eql ['done']
                done()

        context 'injection for asynchronous tests', -> 

            it 'returns a function with done as the only argument if "done"', (done) -> 

                fn = ipso (done, zlib, net) -> 
                args = util.argsOf fn
                args.should.eql ['done']
                done()


        context 'it can inject into before', -> 

            before ipso (http) -> @http = http

            it 'did inject http', ipso (done) -> 

                @http = require 'http'
                done()


        it 'calls each test "runtime" into does as test starts up', ipso (done) -> 

            spec = does._test().runtime.current.spec

            spec.title.should.equal 'calls each test "runtime" into does as test starts up'
            done()


        it 'still fails as it should', -> 

            @resolve = (error) -> 
                #console.log error
                error.name.should.equal 'AssertionError'
                done()

            @fakeit 'fails this', ipso (done) -> 
                true.should.equal 'this is expected to fail'



        it 'preserves the mocha context', ipso (done) ->

            should.exist @resolvingPromise
            done()


        it 'initializes loader with starting cwd', ipso (done) ->

            Loader._test().dir.should.equal process.cwd()
            done()


        it 'passes from within the promise resolution / fullfillment handler', ipso (done) -> 

            @resolvingPromise().then (result) -> 

                result.should.equal 'RESULT'
                done()


        it 'fails from within the promise resolution / fullfillment handler', -> 

            @resolve = (error) -> 
                error.name.should.equal 'AssertionError'
                done()

            @fakeit 'fails this', ipso (done) => 


        it 'injects mode nodules', ipso (done, should) -> 

            should.should.equal require 'should'
            done()


        describe 'it can inject into describe', ipso (vm) -> 

            context 'it can inject into context', ipso (net) -> 

                it 'confirms', -> 

                    vm.should.equal require 'vm'
                    net.should.equal require 'net'


        it 'can inject into synchronous test', ipso (zlib, net) -> 

            net.should.equal require 'net'
            zlib.should.equal require 'zlib'


        it 'fails when injecting undefined node module', (done) ->

            @resolve = (error) -> 
                error.should.match /Cannot find module/
                done()

            @fakeit 'fails this', ipso (facto, i) ->


        it 'succeeds when injecting undefined LocalModule', ipso (LocalModule) ->

            LocalModule.$ipso.PENDING.should.equal true



        it 'injects modules as spectatable', ipso (facto, should) -> 

            should.does.should.be.an.instanceof Function
            facto()


        it 'defines tag() for hook prepping spectatable objects the do not reset stubs at injection', (done) -> 

            ipso.tag.should.be.an.instanceof Function
            done()

        context 'tag()', -> 

            it 'registers spectated object as tagged', (done) -> 

                object = this: 1

                ipso.tag( tagName: object ).then -> 

                    expx = does._test().entities
                    lastone = expx[uuid] for uuid of expx
                    lastone.name.should.equal 'tagName'
                    lastone.tagged.should.equal true
                    object.does.should.be.an.instanceof Function
                    lastone.object.should.equal object
                    done()


            it 'can tag more than one at a time', ipso (facto) -> 

                ipso.tag

                    satelite: class Satelite
                    planet: class Planet
                    star: class Star
                    π: class π

                .then -> 

                    tagged = does._test().tagged

                    should.exist tagged['satelite']
                    should.exist tagged['planet']
                    should.exist tagged['star']
                    should.exist tagged['π']
                    facto()

    context 'mock', -> 

        it 'returns a mock object', -> 

            mock = ipso.mock 'thing'
            mock.is.should.be.an.instanceof Function
            mock.does.should.be.an.instanceof Function

        it 'can assert as self', -> 

            mock1 = ipso.mock 'something'
            mock2 = ipso.mock 'something else'

            try mock1.is mock2
            catch error
                error.should.be.an.instanceof require('assert').AssertionError
                error.should.match /expected/

            try mock1.is 'something else'
            catch error
                error.actual.should.equal 'something'
                error.expected.should.equal 'something else'


        # it 'throws expected functions not called instead of timeout even if timeout is reset', ipso (facto, Something) -> 

        #     @timeout 10
        #     Something.does 
        #         something: -> 'okgood'
        #         somethingElse: -> facto()

        #     Something.something()
        #     # Something.somethingElse()

        #     # 1 | {
        #     # 2 |   "Something": {
        #     # 3 |     "functions": {
        #     # 4 |       "Object.something()": "was called",
        #     # 5 |       "Object.somethingElse()": "was NOT called"
        #     # 6 |     }
        #     # 7 |   }
        #     # 8 | }

        #     # 
        #     # not bothering to try and make a 'passing test' capable 
        #     # of testing that this test fails by timeout
        #     # 



