ipso = require '../lib/ipso'
should  = require 'should'
{deferred} = require 'also'



describe 'ipso', ipso (http) -> 

    before -> 

        @resolvingPromise = deferred (action) -> 
            action.resolve 'RESULT'


    context 'for mocha tests', ->


        it 'goes in front of a test function like this:', ipso -> 

            # console.log @resolvingPromise



        it '[FAILING IS PASSING] still fails as it should', ipso -> 

            true.should.equal 'this is expected to fail'

            #
            # dunno how to test that a test fails
            # this failing is therefore passing
            #


        it 'preserves the mocha context', ipso (done) ->

            should.exist @resolvingPromise
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


        it '[FAILING IS PASSING] still fails no matter how long the chain', ipso (done) -> 

            @resolvingPromise()

            .then (result) => @resolvingPromise()
            .then (result) => @resolvingPromise()
            .then (result) => 

                # true.should.equal 'THIS EARLY FAIL WORKS TOO'
                @resolvingPromise()

            .then (result) => @resolvingPromise()
            .then (result) => @resolvingPromise()
            .then (result) => 

                true.should.equal 'this is expected to fail'
                done()



