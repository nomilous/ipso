describe 'Suite Description', -> 

    context 'Context Title', -> 
        
        @.on 'test', (test) -> 
            console.log START: test
            # nice.. :)

        @.on 'test end', (test) -> 
            console.log FINISHED: test
            # aah... :(


        it 'Test 1 Title', -> 

        it 'Test 2 Title', ->

