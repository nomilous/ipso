ipso = require '../../lib/ipso'

describe 'ipso', -> 



    context """

        module injection
        ================

        * lowercase injects node modules
        * CamelCase injects local modules (recursed from ./lib and ./app)
        * it can be synchronous or asynchronous

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
        * tags can then by used as test arguments to have the corresponding objects injected


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

