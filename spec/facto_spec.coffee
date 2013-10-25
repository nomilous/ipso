{facto} = require '../lib/ipso'
should  = require 'should'

describe 'facto', -> 

    # context 'for mocha tests', ipso (it) -> 
    context 'for mocha tests', ->

        it 'goes in front of your test function like this:', facto -> 


        it 'still fails as it should', facto -> 

            1000.should.equal -1000

            #
            # dunno how to test that a test fails
            # this failing is therefore passing
            #

