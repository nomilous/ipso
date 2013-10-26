ipso = require '../lib/ipso'
should  = require 'should'
{deferred} = require 'also'



describe 'ipso', -> 

    before -> 

        @resolvingPromise = deferred (action) -> 
            action.resolve 'RESULT'


    context 'for mocha tests', ->


        it 'goes in front of a test function like this:', ipso -> 

            # console.log @resolvingPromise



        it 'still fails as it should', ipso -> 

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



        it 'fails from within the promise resolution / fullfillment handler', ipso (done) -> 

            @resolvingPromise().then (result) -> 

                true.should.equal 'this is expected to fail'



        it 'injects mode nodules', ipso (done, mocha) -> 

            mocha.should.equal require 'mocha'
            done()


        it 'can inject into synchronous test', ipso (zlib, net) -> 

            net.should.equal require 'net'
            zlib.should.equal require 'zlib'



        it 'metadatas', ipso (facto, should) -> 

            should.should.equal require 'should'
            facto """







                               this meta-data intentionally left page-like










            """

