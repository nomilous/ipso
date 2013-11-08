ipso = require '../../lib/ipso'

describe 'ipso', -> 





    context """

        module injection
        ================

        * lowercase injects node modules
        * CamelCase injects local modules (recursed from ./lib and ./app)
        * it can be synchronous or asynchronous
        .

    """, ->




        it 'can inject a node module', ipso (events) -> 

            events.should.equal require 'events'


        it 'can inject a Local Module', ipso (done, MyClass) -> 

            #
            # * done will only be the mocha test resolver if the argument's name 
            #   is literally "done"
            #

            MyClass.should.equal require '../../lib/examples/my_class'
            done()







    context """

        tagged module injection
        =======================

        * ipso.tag(list) can be used to register objects by tag
        * it returns a promise for use with async hook resolver (done)
        * tags can then be used as test arguments to have the corresponding objects injected
        .

    """, ->  


        before ipso (done, MyClass) -> 

            ipso.tag

                Subject:  MyClass
                subject:  new MyClass( 'A Title' )

            .then done
            #.then -> done()




        it 'can now inject "subject" of MyClass into all tests', ipso (subject, Subject) -> 

            subject.should.be.an.instanceof Subject
            subject.title.should.equal 'A Title'



        context """

            Stubs and Spies
            ===============

            * injected objects define object.does()
            * it creates stubs or spies on the object

            * IMPORTANT
                * the stubs are function expectations
                * the test fails if they are not called
            .

        """, -> 


            it 'passes this test because STUB subject.thing() was called'.red, ipso (subject) -> 

                subject.does thing: -> return 'Stubbed Thing' 
                subject.thing().should.equal 'Stubbed Thing'



            it 'passes this test because (_)SPY on subject.thing() was called'.red, ipso (subject) -> 

                subject.does _thing: -> #console.log context_of_thing: @
                subject.thing().should.equal 'Original Thing'



        context """

        Asynchronous
        ============

        * done can be called from the stubbed function
        * the test will timeout BUT will report the "function not called" instead of timout 

        """, -> 


            it 'passes this test because STUB with done in it was called'.red, ipso (done, subject) -> 

                subject.does thing: -> done()
                subject.thing()













