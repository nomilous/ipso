{ipso, mock, tag} = require '../../lib/ipso'

does = require 'does'

runtime = -> does._test().runtime
entities = -> does._test().entities

# 
# tests does.reset() here due to the complexity of setting up
# multiple mocha suite stacks to verify the unstubbing across
# various combinations of ancestor hooks
#

before ipso (done, should) -> 

    tag

        GOT: should.exist
        NOT: should.not.exist

    .then done


beforeEach ipso (MyClass) -> MyClass.does each_ROOT_1: -> 

describe 'DESCRIBE', ipso (MyClass) ->

    #
    # TODO: Stubs created in beforeAlls do not create function expectation,
    # TODO: The mocks that they create become injectable by tag into beforeEach hooks 
    #       to assemble expectations on them

    before ipso ->  
        mock1 = mock 'mock1'
        MyClass.does SHOULD_NOT_CAUSE_FAILURE: -> mock1

    before ipso (ModuleMock) ->  
        MyClass.does SHOULD_NOT_CAUSE_FAILURE_EITHER: -> ModuleMock

    beforeEach ipso -> MyClass.does each_DESCRIBE_1: -> 

    context 'OUTER', -> 

        beforeEach ipso -> MyClass.does each_OUTER_1: -> 

        context 'INNER 1', -> 

            before ipso (MyClass) -> MyClass.does failsToCreateThis: -> """

                if beforeAll stubs are not cleared...

                this stub will generate an error, 
                because it is also declared in beforeAll
                in INNER2

            """

            beforeEach ipso -> MyClass.does each_INNER_1: -> 
            beforeEach ipso -> MyClass.does each_INNER_2: -> 


            it 'passes becuase all expected functions are called', ipso -> 

                # console.log '2A' # this runs second :(

                MyClass.each_ROOT_1()
                MyClass.each_DESCRIBE_1()
                MyClass.each_OUTER_1()
                MyClass.each_INNER_1()
                MyClass.each_INNER_2()

        it 'no longer expects inner functions and passes because all outer expectations were called', ipso (MyClass, NOT) ->

            # console.log 1               # this runs first :(
            NOT MyClass.each_INNER_1    # so these,
            NOT MyClass.each_INNER_2    # are testing nothing

            MyClass.each_ROOT_1()
            MyClass.each_DESCRIBE_1()
            MyClass.each_OUTER_1()

        context 'INNER 2', -> 

            beforeEach ipso -> MyClass.does each_INNER_1: -> 
            #beforeEach ipso -> MyClass.does each_INNER_2: -> 

            before ipso (MyClass) -> MyClass.does failsToCreateThis: -> """

                if beforeAll stubs are not cleared...

                this stub will generate an error, 
                because it is also declared in beforeAll
                in INNER1

            """

            context 'ssdf', ->

                it 'cleaned up the stubs created in beforeAll in sibling context', ipso -> 

                    MyClass.each_ROOT_1()
                    MyClass.each_DESCRIBE_1()
                    MyClass.each_OUTER_1()

                    MyClass.each_INNER_1()


    it 'no longer expects OUTER functions', ipso (MyClass, NOT) ->

        NOT MyClass.each_INNER_1
        NOT MyClass.each_INNER_2
        NOT MyClass.each_OUTER_1
        
        # NOT MyClass.each_ROOT_1
        MyClass.each_ROOT_1()
        MyClass.each_DESCRIBE_1()


    context 'USING MOCK TAGS', ->

        beforeEach ipso (mock1) -> mock1.does 

            function1: -> 
            function2: ->

        beforeEach ipso (ModuleMock) -> ModuleMock.does 

            function1: ->
            isTheSameObject: ->

        it 'passes because all expectations on the mock were called', ipso (mock1, ModuleMock) ->

            mockedThing = MyClass.SHOULD_NOT_CAUSE_FAILURE()
            mockedThing.is mock1
            mockedThing.function1()
            mockedThing.function2()


            
            MyClass.each_ROOT_1()
            MyClass.each_DESCRIBE_1()

            moduleMock = MyClass.SHOULD_NOT_CAUSE_FAILURE_EITHER()
            moduleMock.function1()         # <------------------ same object
            ModuleMock.isTheSameObject()   # <------------------ here by different means


            ModuleMock.$save()


after -> # console.log entities()





