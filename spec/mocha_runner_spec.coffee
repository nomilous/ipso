should      = require 'should'
ipso        = require '../lib/ipso'
MochaRunner = require '../lib/mocha_runner'

describe 'MochaRunner', -> 

    it 'runs mocha tests', ipso (facto) -> 

        mocha = new MochaRunner (runner) -> 

            runner.on 'test', (test) -> 

                test.title.should.equal 'Test 1 Title'
                facto()

        mocha.run ['./spec/test_spec.coffee'], ->
