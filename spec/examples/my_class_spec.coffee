{ipso, mock} = require '../../lib/ipso'



# describe (MyClass) -> # will need to override describe to pull this off

describe 'MyClass', ipso (MyClass) ->


    xit 'injected MyClass for use throughout the entire test suite', -> 

        MyClass.should.equal require '../../lib/examples/my_class'


    xcontext """

        module injection (into tests)
        =============================

        * lowercase injects node modules
        * CamelCase injects local modules 
            * recurses ./lib and ./app
            * use ipso.modules(...) to handle name collision
            * successfully injects not yet defined modules with a warning
        * it can be synchronous or asynchronous
        .

    """, ->




        it 'can inject a node module', ipso (events) -> 

            events.should.equal require 'events'


        it 'can inject a Local Module', ipso (done, ModuleName) -> 

            #
            # * done will only be the mocha test resolver if the argument's name 
            #   is literally "done"
            #

            ModuleName.should.equal require '../../lib/testing/recursor/module_name'
            done()


        it 'can inject a not yet written module', ipso (ThereIsNoSourceFileForThisYet) -> 

            ThereIsNoSourceFileForThisYet.does()
            ThereIsNoSourceFileForThisYet.$ipso.save()



    xcontext """

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



        xcontext """

        Asynchronous
        ============

        * done can be called from the stubbed function
        * the test will timeout BUT will report the "function not called" instead of timeout 
        .

        """, -> 


            it 'passes this test because STUB with done in it was called'.red, ipso (done, subject) -> 

                subject.does thing: -> done()
                subject.thing()




        xcontext """

        Stubbing in hooks
        =================

        beforeEach
        ----------

        * the function expectation (stub) applies in all tests preceeded by the hook

        before[All]
        -----------

        * ##undecided

        .


        """, -> 


            beforeEach ipso (subject) -> 

                subject.does
                    _thing: (@spiedArg1) => 
                    _nonExistantFunction: (@spiedArg2) =>
                    #anotherThing: ->


            it 'passes this test because subject.thing() was called'.red, ipso (subject) -> 

                subject.thing()
                subject.callsNonExistantFunction 1001


            context 'nested context', -> 

                it 'still applies the function expectation'.red, ipso (subject) -> 

                    subject.thing( 999 )
                    @spiedArg1.should.equal 999

                    subject.callsNonExistantFunction 1001
                    @spiedArg2.should.equal 1001


        


    xcontext """

    Active Mocks
    ============

    * stubs can return mocks to "nest" function expectations
    .
    

    """, -> 

        beforeEach ipso (http) -> 

            http.does

                createServer: (handler) =>  

                    #
                    # call the handler on nextTick with mocks for req and res
                    #

                    process.nextTick -> handler mock('req'), mock('mock response').does

                        writeHead: ->
                        write: -> 
                        end: ->


                                                    #
                                                    # POSSIBILE??:
                                                    # 
                                                    # * Catching 'undefined is not a function' to record all
                                                    #   calls made to a mock for should to test afterards.
                                                    # 
                                                    #         (js.method_missing?)
                                                    # 

                    #
                    # return a "server" mock with active function expectations that also 
                    # fails the tests if not called...
                    # 
                    # TODO: does.spectate(...  which creates .does(..., is async, this mock probably 
                    #       needs a Sync version
                    #

                    return mock( 'mock server' ).does

                        listen: (@port, args...) => 
                        address: -> 'mock address'



        it '@port is populated or test failes fails'.red, ipso (facto, http) -> 

            server = http.createServer (req, res) -> 

                # console.log REQ: req
                # console.log RES: res

                facto()


            #
            # TODO: make absence of next fail the test
            #
            
            server.listen 3000

            @port.should.equal 3000
            console.log server.address()


    context 'expectation scope', -> 

        it 'klmsdf', ipso (ok) ->

        context 'can set expectations on an object injected into the superscope', -> 

            beforeEach ipso (should) -> MyClass.does function: -> 'mock'

            it 'asserts functions if no resolver or spectateable is injected', ipso -> 

                # MyClass.function().should.equal 'mock'

            xit 'asserts functions if only spectateable is injected', ipso (MyClass) -> 

            xit 'asserts functions if only resolver is injected', ipso (done) -> 

            xit 'asserts functions if resolver and spectateable is injected', ipso (done, MyClass) -> 


        # beforeEach ipso (SomeModule) -> 
        #     SomeModule.does 
        #         someFunction1: ->
        #         someFunction2: ->


        # context 'nested suite', -> 

        #     beforeEach ipso (SomeOtherModule) -> 
        #         SomeOtherModule.does 
        #             someFunction1: ->
        #             someFunction2: ->

        #     it 'has all the expectation failures from ancestor hooks', ipso (facto, SomeModule) -> 

        #         #SomeModule.someFunction1()
        #         facto()

        # xit 'does not have expectation failures from SomeOtherModule even tho it got injected', ipso (facto, SomeOtherModule) -> 

        #     console.log SomeOtherModule
        #     facto()


