{ipso, mock, define} = require 'ipso'

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


it "has created ability to require 'non-existant' in module being tested", ipso (nonExistant) -> 

    nonExistant.does function2: ->
    non = require 'non-existant'

    # console.log non()

    #
    # => { function1: [Function],
    #      property1: 'value1',
    #      function2: [Function] }
    #
    
    non().function2()
