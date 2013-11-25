**experimental/unstable** api changes will still occur (without deprecation warnings)

`npm install ipso` 0.0.15 [license](./license)


Decorator, for testing, with [Mocha](https://github.com/visionmedia/mocha)

All examples in [coffee-script](http://coffeescript.org/).


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
* These **Local Module Injections** can also be stubbed.


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

**PARTIALLY PENDING** It supports tagged objects for multiple subsequent injections.

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


```coffee
before ipso (done, should) -> 

    tag

        Got: should.exist
        Not: should.not.exist

    .then done

it 'has the vodka and the olive', ipso (martini, Got, Not) -> 
    
    Got martini.vodka
    Got martini.olive
    Not martini.gin

    #
    # * there is great value in using **only** local scope in test... (!)
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


And who is Unthahorsten?

* And why was he doing the equivalent of standing in the equivalent of a laboratory.


cli
---

* There is a cli. 
* It is tailored fairly tightly to my size and shape of process. 

**However**, there are options:

```

  Usage: ipso [options]

  Options:

    -h, --help            output usage information
    -V, --version         output the version number
    -w, --no-watch        Dont watch spec and src dirs.
    -n, --no-env          Dont load .env.test
    -m, --mocha           Use mocha.
    -e, --alt-env [name]  Loads .env.name
        --spec    [dir]   Specify alternate spec dir.
        --src     [dir]   Specify alternate src dir.
        --lib     [dir]   Specify alternate compile target.

```

### Highlight

It can quickly start up a node-inspector session on a v8 debugger socket. It may at some point seamlessly attach to the running tests, with `Module.does(...)` specifying breakpoints. (that would be very! very! nice...)

```
$ ipso --mocha -e name
ipso: warning: .env.name is PRODUCTION
ipso: loaded .env.name
ipso: watching directory: ./spec
ipso: watching directory: ./src
>
>
> inspect 3001 5860 lib/examples/basic.js
> 
> debugger listening on port 5860    <----------------------------
> Node Inspector v0.5.0
> info: socket.io started
> Visit http://127.0.0.1:3001/debug?port=5860 to start debugging.
>       =====================================
```

### Specific!ness

It watches for ./src and ./spec changes and runs the changed.

`ipso --mocha --src [dir] --spec [dir] --lib [dir]`

* ./src changes will be compiled into ./lib/...
* the corresponding test will then be run from ./spec/...
* the followingly illustrated "path echo" **is assumed to ALWAYS be the case**

```
 src/same/dirname/source_name.coffee
spec/same/dirname/source_name_spec.coffee
```
