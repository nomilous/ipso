{ipso, mock, Mock, define} = require 'ipso'

before ipso -> 

    #
    # create a mock to be returned by the module function
    #

    mock( 'nonExistant' ).with

        function1: ->
        property1: 'value1'

    define

        # 
        # define the module
        # 
        # * get() is defined on the scope of the 
        #   exporter that creates the stub module,
        # 
        # * it returns the specified mock
        #

        '$non-existant': -> return get 'nonExistant'

        #
        # define node_module called 'missing' with 
        # 2 exported classes
        #

        missing: -> 

            ClassName: Mock 'ClassName'
            Another:   Mock 'Another'



it "has created ability to require 'non-existant' in module being tested", 

    ipso (nonExistant, should) -> 

        nonExistant.does function2: ->
        non = require 'non-existant'

        # console.log require 'missing'

        # console.log non()

        #
        # => { function1: [Function],
        #      property1: 'value1',
        #      function2: [Function] }
        #
        
        non().function2()



it "can require 'missing' and create expectations on the Class / instance", 

    ipso (ClassName, should) ->

        ClassName.does 

            constructor: (arg) -> arg.should.equal 'ARG'
            someFunction: -> 




        #
        # this would generally be elsewhere (in the module being tested)
        #

        missing  = require 'missing'
        instance = new missing.ClassName 'ARG'
        instance.someFunction()

