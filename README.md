**due homage:** [RSpec](http://rspec.info/)

**experimental/unstable** api changes will still occur (**without** deprecation warnings)

`npm install ipso` 0.0.22 [license](./license)

* Injection Decorator, for mocking and stubbing, with [Mocha](https://github.com/visionmedia/mocha)
* Now also a [modulename aliasing bridge](component_example), for using [components](https://github.com/component/component), serverside


Almost all examples in [coffee-script](http://coffeescript.org/).


What is this `ipso` thing?
--------------------------

[The Short Answer](https://github.com/nomilous/vertex/commit/a4b0ef4c6bc14874f5b7d8ff3e5bcbcf4d45edc6)

The Long Answer, ↓

### (test/) Injection Decorator

It is placed in front of the test functions.

```coffee
ipso = require 'ipso'

it 'does something', ipso (done) -> 

    done() # as usual

```

or js:

```js
ipso = require('ipso');

it('does something', ipso(  function(done) {
  
  done();

}  ));

```

It can inject node modules into suites.

```coffee

describe 'it can inject into describe', ipso (vm) -> 
    context 'it can inject into context', ipso (net) -> 
        it 'confirms', -> 

            vm.should.equal  require 'vm'
            net.should.equal require 'net'

```

It can inject node modules into tests.

```coffee

it 'does something', ipso (done, http) -> 

    http.should.equal require 'http'

```

It can inject dasherized modules using mixed case.

```coffee

it 'does something', ipso (dashedName) ->

    dashedName.should.equal require 'dashed-name'

```

**IMPORTANT**: `done` will only contain the test resolver if the argument's signaure is literally "done" and it in the first position.

In other words.

```coffee

it 'does something', ipso (finished, http) -> 

#
# => Error: Cannot find module 'finished' 
# 
# And the problem becomes more subtle if there IS a module called 'finshed' installed...
# 

```


It defines `.does()` on each injected module for use as a **stubber**.

```coffee

it 'creates an http server', ipso (done, http) -> 

    http.does 
        createServer: -> 
        anotherFunction: -> 

    http.createServer()
    done()

```

It uses mocha's JSON diff to display failure to call the stubbed function.

```json

      actual expected
      
      1 | {
      2 |   "http": {
      3 |     "functions": {
      4 |       "Object.createServer()": "was called"
      5 |       "Object.anotherFunction()": "was NOT called"
      6 |     }
      7 |   }
      8 | }

```

or, (depending on your mocha version)

```json

      + expected - actual

       {
         "http": {
           "functions": {
             "Object.createServer()": "was called",
      +      "Object.anotherFunction()": "was called"
      -      "Object.anotherFunction()": "was NOT called"
           }
         }
       }

```

The stub replaces the actual function on the module and can therefore return a suitable mock. 

```coffee
http = require 'http'
class MyServer
    listen: (opts, handler) -> 
        http.createServer(handler).listen opts.port
```

```coffee
{ipso, mock} = require 'ipso'

it 'creates an http server and listens at opts.port', ipso (done, http, MyServer) -> 

    http.does
        createServer: -> 
            return mock('server').does
                listen: (port) ->
                    port.should.equal 3000
                    done()

    MyServer.listen port: 3000, (req, res) -> 

```

You may have noticed that `MyServer` was also injected in the previous example.

* The injector recurses `./lib` and `./app` for the specified module.
* It does so only if the module has a `CamelCaseModuleName` in the injection argument's signature
* It searches for the underscored equivalent `./lib/**/*/camel_case_module_name.js|coffee`
  * TODO: make search strategy configurable
* These **Local Module Injections** can also be stubbed.


It can call the original function from within the stub.

```coffee

{ipso, original} = require 'ipso'

it 'can fake the existance of a file', ipso (fs) -> 

    fs.does
        readFileSync: (filename) -> 

            return 'mock file contents' if filename is 'something'

            #
            # otherwise call onward to original with arguments
            # ------------------------------------------------
            # 
            # * original() references the currently running stub's original
            # * it therefore only functions as expected from inside running stub
            # 

            return original arguments

```

It can create multiple function expectation stubs ( **and spies** ).

```coffee

it 'can create multiple expectation stubs', ipso (done, Server) -> 

    Server.does 

        _listen: ->

            # console.log arguments 

            console.log """

                _underscore denotes a spy function
                ==================================

                * the original will be called after the spy (this function)
                * both will receive the same arguments

            """

        anotherFunction: -> 

    Server.start()


```

**IMPORTANT** Stubs set up in before (All) hooks are not enforced as expectations

```coffee

{ipso, mock} = require 'ipso'


before ipso ->
    mock('thing').does
        function1: -> return 'value1'


beforeEach ipso (thing) -> 

    #
    # injected mock thing (as defined in above)
    #

    thing.does
        function2: -> return 'value2'



it 'calls function2', ipso (thing) -> 

    thing.function2() 

    #
    # does not fail even tho function1() was not called
    #


```

Mocks can define properties using `.with()`

```coffee

{ipso, mock} = require 'ipso'

before ipso ->
    mock('thing').with
        property1: 'value1'
        property2: 'value2'

beforeEach ipso (thing) -> 

    thing.with

        property2: 'overwrite value2'

    .does

        function1: -> 'with and does are chainable'
        function2: -> 


```

* Note that `.with()` only exists on objects created with ipso.mock()


**PENDING (unlikely, use tags, see below)** It can create future instance stubs (on the prototype)

```coffee

it 'can create multiple expectation stubs', ipso (done, Periscope, events, should) -> 
    
    # Periscope.$prototype.does  (dunno yet)
    Periscope.prototype.does 

        measureDepth: -> return 30

        _riseToSurface: (distance, finishedRising) -> 
            distance.should.equal 30

        _openLens: -> 
            @videoStream.codec.should.equal πr²

            #
            # note: That `@` a.k.a. `this` refers to the instance context 
            #       and not the test context. It therefore has access to
            #       properties of the Periscope instance.
            # 


    periscope = new Periscope codec: πr²
    periscope.up (error, eyehole) -> 

        should.not.exist error
        eyehole.should.be.an.instanceof events.EventEmitter
        done()

```

It supports taging objects for multiple subsequent injections by tag.

```coffee

context 'creates tagged objects for injection into multiple nested tests', -> 
    
    before ipso (ClassName) ->

        ipso.tag 

            instanceA: new ClassName 'type A'
            instanceB: new ClassName 'type B'
            client:    require 'socket.io-client'

    it 'can test with them', (instanceA, instanceB, client) -> 
    it 'and again', (instanceA, instanceB) -> 

```


### Complex Usage


It can create active mocks for fullblown mocking and stubbing

```coffee

beforeEach ipso (done, http) -> 

    http.does
        createServer: (handler) =>  
            process.nextTick ->

                #
                # mock an actual "hit"
                #

                handler mock('req'), mock('mock response').does

                    writeHead: -> 
                    write: ->
                    end: ->
            
            return ipso.mock( 'mock server' ).does

                listen: (@port, args...) => 
                address: -> 'mock address object'

                #
                # note: '=>' pathway from hook's root scope means @port
                # refers to the `this` of the hook's root scope - which 
                # is shared with the tests themselves, so @port becomes 
                # available in all tests that are preceeded by this     hook
                # 

it 'creates a server, starts listening and responds when hit', ipso (facto, http) ->

    server = http.createServer (req, res) -> 

        res.writeHead 200
        res.end()
        facto()

    server.listen 3000
    @port.should.equal 3000

```
```json

      actual expected
      
       1 | {
       2 |   "http": {
       3 |     "functions": {
       4 |       "Object.createServer()": "was called"
       5 |     }
       6 |   },
       7 |   "mock server": {
       8 |     "functions": {
       9 |       "Object.listen()": "was called",
      10 |       "Object.address()": "was called"
      11 |     }
      12 |   },
      13 |   "mock response": {
      14 |     "functions": {
      15 |       "Object.writeHead()": "was called",
      16 |       "Object.write()": "was NOT called",  <--------------------
      17 |       "Object.end()": "was called"
      18 |     }
      19 |   }
      20 | }

```


It can **create** entire module stubs

```coffee
{ipso, mock, Mock, define} = require 'ipso'

before ipso -> 

    #
    # create a mock to be returned by the module function
    #

    mock( 'nonExistant' ).with

        function1: ->
        property1: 'value1'


    #
    # define(listOfFunctions)
    # -----------------------
    # 
    # * Keys from the list become module names
    # * Each function is run by the module stubber
    # * The returned object is exported as the module
    #

    define

        #
        # define a module that exports two class definitions
        # --------------------------------------------------
        # 
        # * Mock() (capital 'M') creates mock classes
        # 
        # * .with() can be used to define a baseset of functions 
        #   and property stubs.
        # 
        # * The mock entity can be injected by tag/name for 
        #   per test configuration of function expectations
        #   using .does()
        # 

        missing: -> 

            ClassName: Mock 'ClassName'
            Another:   Mock('Another').with(...)

        # 
        # define a module that exports a single function
        # ----------------------------------------------
        # 

        'non-existant': -> ->

            #
            # * The second function becomes the exported function of the module.
            # 
            # * It will be retured by `require 'non-existant'`
            # 
            # * get() is defined in the module scope to enable reference
            #   to mocks and tags defined in this test scope.
            #

            return get 'nonExistant'



it "has created ability to require 'non-existant' in module being tested", 
  
    ipso (nonExistant, SubClass1) -> 

        nonExistant.does function2: ->
        non = require 'non-existant'

        console.log non()

        #
        # => { function1: [Function],
        #      property1: 'value1',
        #      function2: [Function] }
        #


it "can require 'missing' and create expectations on the Class / instance", 

    ipso (ClassName, should) ->

        ClassName.does 

            constructor: (arg) -> arg.should.equal 'ARG'
            someFunction: -> 




        #
        # this would generally be elsewhere (in the module being tested)
        #

        missing  = require 'missing'
        instance = new missing.ClassName 'ARG'
        instance.someFunction()


```

* Use case

  * Testing [component](http://component.io/) based clientside code without running a browser.

* **IMPORTANT / WARNING**
  
  * It is a clunky interface and may change drastically.
  * It tricks `require` into loading the module by tailoring the behaviours 
    of fs.readFileSync, statSync and lstatSync (a not very eloquent method...)
  * It cannot be reversed (yet), so the stub remains for the duration of the
    process that created it.


it has been shaken, not stirred


```coffee

{ipso, tag, define, Mock} = require '../lib/ipso'

before ipso (should) -> 

    tag

        Got: should.exist
        Not: should.not.exist

    define 

        martini: -> Mock 'VodkaMartini'


it 'has the vodka and the olive', ipso (VodkaMartini, Got, Not) -> 

    VodkaMartini.with 

        olive: true

    .does

        constructor: -> @vodka = true
        shake: ->

    Martini  = require 'martini'
    instance = new Martini

    Got instance.vodka
    Got instance.olive
    Not instance.gin

    instance.shake()

    try instance.stir()



    #
    # ps. there is great value in using **only** local scope in tests... (!, later)
    # 

```


It supports promises.

```coffee

it 'fails the test on the first rejection in the chain', ipso (facto, Module) -> 

    Module.functionThatReturnsAPromise()

    .then -> Module.functionThatReturnsAPromise()
    .then -> Module.functionThatReturnsAPromise()
    .then -> Module.functionThatReturnsAPromise()
    .then -> facto()

```

Ipso Facto

```coffee

it 'does many things to come', ipso (facto, ...) -> 

    facto[MetaThings]()

    #
    # facto() calls mocha's done() in the background
    #

```

What MetaThings? 

* well, ... (( the brief brainstorm suggested a Planet-sized Plethora of Particularly Peachy Possibilities Perch Patiently Poised Pending a Plunge into **That** rabbit hole.


There is a [cli](https://github.com/nomilous/ipso-cli)

* It assists with the overhead of dev using coffee-script, specifically the compile.then -> runTest on changes in src/**/*



And who is Unthahorsten?

* And why was he doing the equivalent of standing in the equivalent of a laboratory.

