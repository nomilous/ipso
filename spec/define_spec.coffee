{ipso, mock, define} = require '../lib/ipso'


describe 'define', ipso (should) -> 


    it 'is exported by ipso', 

        ipso (Define) -> Define.should.eql define

    context 'replaces fs readFileSync, lstatSync and statSync', ->

        it 'to trick require into loading non existant modules', 

            ipso (Define, fs) -> 

                Define 'nodule': -> 

                fs.readFileSync.toString().should.match /MODIFIED BY ipso.define/
                fs.lstatSync.toString().should.match /MODIFIED BY ipso.define/
                fs.statSync.toString().should.match /MODIFIED BY ipso.define/   

                require 'nodule'

    it 'it does not replace fs functions unless necessary - ipso.define() was used', 

            ipso (Define, fs) -> 

                #Define 'nodule': -> 

                fs.readFileSync.toString().should.not.match /MODIFIED BY ipso.define/
                fs.lstatSync.toString().should.not.match /MODIFIED BY ipso.define/
                fs.statSync.toString().should.not.match /MODIFIED BY ipso.define/   


    it 'calls activate (to replace fs functions) only once', 

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

                Define '$non-existant': -> 

                    function1: -> 'RESULT1'
                    function2: -> 'RESULT2'

                non = require('non-existant')()
                non.function1().should.equal 'RESULT1'
                non.function2().should.equal 'RESULT2'


        it 'has get() in scope (at require time) to return previously defined mock object',

            ipso (Define) -> 

                mock( 'mock_object' ).does

                    expectedFunction: -> 'RESULT'

                Define

                    '$object': -> get 'mock_object'

                obj = require('object')()
                obj.expectedFunction().should.equal 'RESULT'



    context 'modules that export a list of functions', ->

        it 'can be defined',

            ipso (Define) -> 

                Define missing1: -> 
                m = require 'missing1'


        it 'runs the function to create the module definition',

            ipso (Define) -> 

                Define missing2: -> 'value'
                m = require 'missing2'
                m.should.equal 'value'


        context 'defines mock() in the module scope', -> 

            before ipso (Define) -> 

                 Define missing3: -> 

                    SubClass1: mock 'SubClass1'


            it 'can inject the mocks that compose the new module', 

                ipso (SubClass1) ->

                    SubClass1.does function: ->
                        
                    r = require 'missing3'
                    console.log r



    context 'modules that export a class', ->


