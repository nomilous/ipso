**experimental/unstable** api changes will still occur (without deprecation warnings) <br\>
`npm install ipso` 0.0.10 [license](./license)


Decorators, for testing, with [Mocha](https://github.com/visionmedia/mocha)

All examples in [coffee-script](http://coffeescript.org/).

ipso
====

### Injection Decorator

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

* `done` will only contain the test resolver if the argument's signaure is literally "done" and is in the first position.


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
it 'creates an http server and listens at opts.port', ipso (done, http, MyServer) -> 

    http.does 
        createServer: -> 
            listen: (port) -> 
                port.should.equal 3000

    MyServer.listen port: 3000, (req, res) -> 
    done()

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
                    * reference args can probably be `tweaked`
                        * just occurred to me now
                            * have not verified...
                                * could be useful
                                    * could also confuze

            """

        otherThing: -> 

    Server.start()


```


**PENDING** It can `save()` newly written stubs into `./src/**/*` as "first draft"

```coffee

it 'can detect a non existant LocalModule being injected', ipso (done, NewModuleName) -> 

    #
    # when ./src/**/* contains no file called new_module_name.coffee
    # --------------------------------------------------------------
    # 
    # * a standin module is injected
    # * a warning is displayed
    # * NewModuleName.does() can still be used to define stubs
    # * NewModuleName.$ipso.save( 'tag', 'relative/path' ) can use template
    #   defined in ~/.ipso/templates/tag and the function stubs to create
    #   the new source file at ./src/relative/path/new_module_name.coffee
    # 


```

**PENDING** It can create future instance stubs (on the prototype)

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

 It supports injection of non-js-eval-able module names or cases where the local module search fails


```coffee

ipso = require('ipso').modules 
    engine: 
        require: 'engine.io'
    Proxy:                              #
        require: './lib/proxy/server'   # * Because the filenames are the same
    Core:                               #   so injecting `Server` will fail.
        require: './lib/core/server'    # 
                                        #
...
    
    it 'can inject by config', ipso (done, engine, Proxy, Core) -> 

        #
        # ...
        #

```
* IMPORTANT
    * `require` in the above config is a subkey, and **not the require function itself**
    * The path should be relative to `process.cwd()`, not `__dirname`


**PARTIALLY PENDING** It supports tagged objects for multiple subsequent injections.

```coffee

context 'creates tagged objects for injection into multiple nested tests', -> 
    
    before ipso (done, ClassName) ->

        ipso.tag 

            instanceA: new ClassName 'type A'
            instanceB: new ClassName 'type B'

        .then done

    it 'can test with them', (instanceA, instanceB) -> 
    it 'and again', (instanceA, instanceB) -> 

```


### Complex Usage / Current Caveats

To test in cases where the call chain being tested has an asynchronous step the `done()` can be put into the mock.

```coffee
it 'can stop the http server', (done, http, Server) -> 
    
    http.does 
        createServer: ->
            listen: (args...) -> 
                process.nextTick args.pop() # blind callback lastarg(), 
                                            # mimics async listen step
            close: -> done()

    Server.create (server) -> server.stop()

```

Previous stubs are flushed from **ALL** modules at **EVERY** injection
    
* this may be temporary (pending tighter integration with mocha)

```coffee
    
    beforeEach ipso (done, http) -> 

        http.does createServer: -> 'mock server'
        done()

    it 'no longer has the stub in this test', (done, http) -> 

        http.createServer().should.equal 'mock server' # fails

```

**PENDING** It can create active mocks for fullblown stubbing whole modules

```coffee
beforeEach ipso (done, http) -> 

    http.does
        createServer: (handler) =>  
            process.nextTick ->

                #
                # mock an actual "hit"
                #

                handler mock('req').does(...), mock('res').does(...)
            
            return mock( 'server' ).does

                listen: (@port) =>
                address: -> 'mock address'


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
