{ipso, mock, define} = require '../lib/ipso'


describe 'define', ipso (should) -> 


    it 'is exported by ipso', 

        ipso (Define) -> Define.should.eql define



    it 'calls activate only once', 

        ipso (Define) -> 

            count = 0
            Define.does _activate: -> count++

            Define 'xmodule': -> 
            Define 'ymodule': -> 
            Define 'zmodule': ->

            count.should.equal 1



    context 'modules that export a single function', -> 

        it 'can be defined',

            ipso (Define) -> 

                Define 'non-existant': -> 

                    function1: -> 'RESULT1'
                    function2: -> 'RESULT2'

                non = require('non-existant')()
                non.function1().should.equal 'RESULT1'
                non.function2().should.equal 'RESULT2'


        it 'has get() in scope to (at require time) return previously defined mock object',

            ipso (Define) -> 

                mock( 'mock_object' ).does

                    expectedFunction: -> 'RESULT'

                Define

                    'object': -> get 'mock_object'

                obj = require('object')()
                obj.expectedFunction().should.equal 'RESULT'




    context 'modules that export an object', ->
    context 'modules that export a class', ->


