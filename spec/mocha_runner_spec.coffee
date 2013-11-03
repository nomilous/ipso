should      = require 'should'
ipso        = require '../lib/ipso'
MochaRunner = require '../lib/mocha_runner'

describe 'MochaRunner', -> 

    it 'defines a global event emitter', (done) -> 

        MochaRunner.on.should.be.an.instanceof Function
        done()



    it 'runs mocha tests', ipso (facto) -> 

        MochaRunner.on 'spec_event', ipso.once (payload) -> 

            # console.log payload

            payload.source.should.equal 'mocha'
            should.exist payload.event
            should.exist payload.data
            facto()
            

        MochaRunner.create()
        .run ['./spec/test_spec.coffee'], -> 
