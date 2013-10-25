ipso = require '../lib/ipso'
should  = require 'should'
{defer} = require 'when'

describe 'ipso', -> 

    before -> 

        @resolvingPromise = ->
            action = defer()
            action.resolve 'RESULT'
            action.promsise

    context 'for mocha tests', ->

        it 'goes in front of a test function like this:', ipso -> 

            # console.log @resolvingPromise


        it 'still fails as it should', ipso -> 

            1000.should.equal -1000

            #
            # dunno how to test that a test fails
            # this failing is therefore passing
            #


        it 'preserves the mocha context', ipso (done) ->

            should.exist @resolvingPromise
            done()

