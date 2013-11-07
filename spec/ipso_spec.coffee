ipso = require '../lib/ipso'
should  = require 'should'
{deferred, util} = require 'also'
Loader = require '../lib/loader'
does = require 'does'



describe 'ipso', -> 

    before -> 

        @resolvingPromise = deferred (action) -> 
            action.resolve 'RESULT'


    context 'for mocha tests', ->


        it 'goes in front of a test function like this:', ipso -> 

            # console.log @resolvingPromise


        context 'injection for synchronous tests', -> 

            it 'returns a function with done as the only argument if no "done"', (done) -> 

                #
                # injection is asynchronous even when mocha test is not
                #

                fn = ipso (zlib, net) -> 
                args = util.argsOf fn
                args.should.eql ['done']
                done()

        context 'injection for asynchronous tests', -> 

            it 'returns a function with done as the only argument if "done"', (done) -> 

                fn = ipso (done, zlib, net) -> 
                args = util.argsOf fn
                args.should.eql ['done']
                done()


        context 'it can inject into before', -> 

            before ipso (http) -> @http = http

            it 'did inject http', -> 

                @http = require 'http'



        it '[FAILING IS PASSING] still fails as it should', ipso -> 

            true.should.equal 'this is expected to fail'

            #
            # dunno how to test that a test fails
            # this failing is therefore passing
            #


        it 'preserves the mocha context', ipso (done) ->

            should.exist @resolvingPromise
            done()


        it 'initializes loader with starting cwd', ipso (done) ->

            Loader._test().dir.should.equal process.cwd()
            done()


        it 'can assign module list into loader', (done) -> 

            ipso.modules 
                tag1: require: '../lib/require/argument'
                tag2: require: 'module-name'

            Loader._test().modules.should.eql 
                tag1: require: '../lib/require/argument'
                tag2: require: 'module-name'

            done()


        it 'throws error if modules is loaded into tag', (done) -> 

            try ipso.modules 
                tag2: require 'http'

            catch error
                error.message.should.equal 'ipso.module expects { tagName: { require: "path/or/name" } }'
                done()

        it 'throws error if require is not a subkey', (done) -> 

            try ipso.modules 
                tag2: erquire:'http'

            catch error
                error.message.should.equal 'ipso.module expects { tagName: { require: "path/or/name" } }'
                done()

        it 'ipso.modules returns ipso', (done) -> 

            ipso.modules 
                tag: require: 'moo'

            .should.equal ipso
            done()


        it 'passes from within the promise resolution / fullfillment handler', (done) -> 

            @resolvingPromise().then (result) -> 


                result.should.equal 'RESULT'
                done()



        it '[FAILING IS PASSING] fails from within the promise resolution / fullfillment handler', ipso (done) -> 

            @resolvingPromise()

            .then (result) => @resolvingPromise()
            .then (result) -> 

                true.should.equal 'this is expected to fail'


        it 'injects mode nodules', ipso (done, mocha) -> 

            mocha.should.equal require 'mocha'
            done()


        it 'can inject into synchronous test', ipso (zlib, net) -> 

            net.should.equal require 'net'
            zlib.should.equal require 'zlib'


        it '[FAILING IS PASSING] fail when injecting undefined module', ipso (facto, i) -> 


        it 'metadatas', ipso (facto, should) -> 

            should.should.equal require 'should'
            facto meta: data = """







                               this meta-data intentionally left page-like










            """


        it 'injects spectatable modules when called with ipso (facto, mod, ule, names) ->', ipso (facto, should) -> 

            should.does.should.be.an.instanceof Function
            facto()


        it 'defines tag() for hook prepping spectatable objects the do not reset stubs at injection', (done) -> 

            ipso.tag.should.be.an.instanceof Function
            done()

        context 'tag()', -> 

            it 'registers spectated object as tagged', (done) -> 

                object = this: 1

                ipso.tag( tagName: object ).then -> 

                    expx = does._test().spectacles
                    lastone = expx[uuid] for uuid of expx
                    lastone.name.should.equal 'tagName'
                    lastone.tagged.should.equal true
                    object.does.should.be.an.instanceof Function
                    lastone.object.should.equal object
                    done()


            it 'can tag more than one at a time', ipso (facto) -> 

                ipso.tag

                    satelite: class Satelite
                    planet: class Planet
                    star: class Star
                    π: class π

                .then -> 

                    tagged = does._test().tagged

                    should.exist tagged['satelite']
                    should.exist tagged['planet']
                    should.exist tagged['star']
                    should.exist tagged['π']
                    facto()








