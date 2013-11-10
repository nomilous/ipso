ipso = require 'ipso'

runtime: -> does._test().runtime
objects: -> does._test().spectacles

# 
# tests does.reset() here due to the complexity of setting up
# multiple mocha suite stacks to verify the unstubbing across
# various combinations of ancestor hooks
#

beforeEach ipso (MyClass) -> MyClass.does each_ROOT_1: -> 

describe 'DESCRIBE', ipso (MyClass) ->

    beforeEach ipso -> MyClass.does each_DESCRIBE_1: -> 

    context 'OUTER', -> 

        beforeEach ipso -> MyClass.does each_OUTER_1: -> 

        context 'INNER', -> 

            beforeEach ipso -> MyClass.does each_INNER_1: -> 
            beforeEach ipso -> MyClass.does each_INNER_2: -> 

            it 'passes becuase all expected functions are called', ipso -> 

                MyClass.each_ROOT_1()
                MyClass.each_DESCRIBE_1()
                MyClass.each_OUTER_1()
                MyClass.each_INNER_1()
                MyClass.each_INNER_2()

        it 'no longer expects INNER functions', ipso (MyClass, should) ->

            should.not.exist MyClass.each_INNER_1
            should.not.exist MyClass.each_INNER_2

            MyClass.each_ROOT_1()
            MyClass.each_DESCRIBE_1()
            MyClass.each_OUTER_1()

    it 'no longer expects OUTER functions', ipso (MyClass, should) ->

        should.not.exist MyClass.each_INNER_1
        should.not.exist MyClass.each_INNER_2
        should.not.exist MyClass.each_OUTER_1
        
        MyClass.each_ROOT_1()
        MyClass.each_DESCRIBE_1()

