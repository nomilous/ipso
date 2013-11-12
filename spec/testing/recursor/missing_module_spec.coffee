ipso = require '../../../lib/ipso'


describe 'MissingModule', ipso (MissingModule) -> 
    
    context 'things', -> 

        beforeEach ipso -> MissingModule.does 

            function1: ->
            function2: ->
            function3: ->

        it 'does', ipso -> 

            MissingModule.function1()
            MissingModule.function2()
            MissingModule.function3()


    context 'other stuff', -> 

        beforeEach  ipso -> MissingModule.does function4: ->
        it 'does',  ipso -> MissingModule.function4()


    after -> # MissingModule.$save 'factory'

