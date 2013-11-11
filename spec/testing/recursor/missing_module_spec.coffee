ipso = require '../../../lib/ipso'


# describe 'saveable injection fails here', (MissingModule) -> # ???
describe 'unwritten module', -> 
    
    context 'things', -> 

        beforeEach ipso (MissingModule) -> MissingModule.does 

            function1: ->
            function2: ->
            function3: ->

        it 'does', ipso (MissingModule) -> 

            MissingModule.function1()
            MissingModule.function2()
            MissingModule.function3()
            #done()


    context 'other stuff', -> 

        beforeEach ipso (MissingModule) -> MissingModule.does function4: ->
        it 'does', ipso (MissingModule) -> MissingModule.function4()


after ipso (MissingModule) -> 


    console.log todo: 'um ? functions count is -3'

    #
    # when to allow (safely) save() ?
    # 

    MissingModule.$save()

