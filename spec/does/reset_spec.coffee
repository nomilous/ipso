{ipso, mock, tag} = require '../../lib/ipso'

runtime: -> does._test().runtime
objects: -> does._test().spectacles

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

    beforeEach ipso -> MyClass.does each_DESCRIBE_1: -> 

    context 'OUTER', -> 

        beforeEach ipso -> MyClass.does each_OUTER_1: -> 

        context 'INNER', -> 

            beforeEach ipso -> MyClass.does each_INNER_1: -> 
            beforeEach ipso -> MyClass.does each_INNER_2: -> 

            it 'passes becuase all expected functions are called', ipso -> 

                #
                # should still pass
                #

                MyClass.each_ROOT_1()
                MyClass.each_DESCRIBE_1()
                MyClass.each_OUTER_1()
                MyClass.each_INNER_1()
                MyClass.each_INNER_2()

        it 'no longer expects INNER functions', ipso (MyClass, NOT) ->

            NOT MyClass.each_INNER_1
            NOT MyClass.each_INNER_2

            MyClass.each_ROOT_1()
            MyClass.each_DESCRIBE_1()
            MyClass.each_OUTER_1()

    it 'no longer expects OUTER functions', ipso (MyClass, NOT) ->

        NOT MyClass.each_INNER_1
        NOT MyClass.each_INNER_2
        NOT MyClass.each_OUTER_1
        
        #NOT MyClass.each_ROOT_1
        MyClass.each_ROOT_1()
        MyClass.each_DESCRIBE_1()

    context 'USING MOCK TAGS', ->

        beforeEach ipso (mock1) -> mock1.does 

            function1: -> 
            function2: ->

        it 'fails because expectations on the mock were not called', ipso (mock1) ->

            mockedThing = MyClass.SHOULD_NOT_CAUSE_FAILURE()

            mockedThing.is mock1
            mockedThing.function1()

            





