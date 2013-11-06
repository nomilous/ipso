ipso = require '../lib/ipso'
should  = require 'should'
{deferred} = require 'also'
Loader = require '../lib/loader'



describe 'ipso', -> 

    before -> 

        @resolvingPromise = deferred (action) -> 
            action.resolve 'RESULT'


    context 'for mocha tests', ->


        it 'goes in front of a test function like this:', ipso -> 

            # console.log @resolvingPromise


        context 'it can inject into context', ipso (http) -> 

            it 'has injected http', (done) -> 

                http.should.equal require 'http'
                done()

        context 'it can inject into before', -> 

            before ipso (http) -> @http = http

            it 'did inject http', -> 

                @http = require 'http'



        it '[FAILING IS PASSING] still fails as it should', ipso -> 

            true.should.equal 'this is expected to fail'

            #
            # dunno how to test that a test fails
            # this failing is therefore passing
            #


        it 'preserves the mocha context', ipso (done) ->

            should.exist @resolvingPromise
            done()


        it 'initializes loader with starting cwd', ipso (done) ->

            Loader._test().dir.should.equal process.cwd()
            done()


        it 'can assign module list into loader', (done) -> 

            ipso.modules 
                tag1: require: '../lib/require/argument'
                tag2: require: 'module-name'

            Loader._test().modules.should.eql 
                tag1: require: '../lib/require/argument'
                tag2: require: 'module-name'

            done()


        it 'throws error if modules is loaded into tag', (done) -> 

            try ipso.modules 
                tag2: require 'http'

            catch error
                error.message.should.equal 'ipso.module expects { tagName: { require: "path/or/name" } }'
                done()

        it 'throws error if require is not a subkey', (done) -> 

            try ipso.modules 
                tag2: erquire:'http'

            catch error
                error.message.should.equal 'ipso.module expects { tagName: { require: "path/or/name" } }'
                done()

        it 'ipso.modules returns ipso', (done) -> 

            ipso.modules 
                tag: require: 'moo'

            .should.equal ipso
            done()


        it 'passes from within the promise resolution / fullfillment handler', (done) -> 

            @resolvingPromise().then (result) -> 


                result.should.equal 'RESULT'
                done()



        it '[FAILING IS PASSING] fails from within the promise resolution / fullfillment handler', ipso (done) -> 

            @resolvingPromise()

            .then (result) => @resolvingPromise()
            .then (result) -> 

                true.should.equal 'this is expected to fail'


        it 'injects mode nodules', ipso (done, mocha) -> 

            mocha.should.equal require 'mocha'
            done()


        it 'can inject into synchronous test', ipso (zlib, net) -> 

            net.should.equal require 'net'
            zlib.should.equal require 'zlib'


        it '[FAILING IS PASSING] fail when injecting undefined module', ipso (facto, i) -> 


        it 'metadatas', ipso (facto, should) -> 

            should.should.equal require 'should'
            facto meta: data = """







                               this meta-data intentionally left page-like










            """


        it 'injects spectatable modules when called with ipso (facto, mod, ule, names) ->', ipso (facto, should) -> 

            should.does.should.be.an.instanceof Function
            facto()


