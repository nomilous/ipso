**experimental/unstable** api changes will still occur (without deprecation warnings) <br\>
`npm install ipso` 0.0.10 [license](./license)


Injection decorator, for tests, with [Mocha](https://github.com/visionmedia/mocha). (others unknown)

All examples in [coffee-script](http://coffeescript.org/).

ipso
====

### Injection Decorator

It is placed in front of the test function.

```coffee
ipso = require 'ipso'

it 'does something', ipso (done) -> 

    done() # as usual

```

It can inject node modules.

```coffee

it 'does something', ipso (done, http) -> 

    http.should.equal require 'http'

```

* `done` will only contain the test resolver if the argument's signaure is literally "done" and is in the first position.


It defines `.does()` on each injected module to stub with function expectations.

```coffee

it 'creates an http server', ipso (done, http) -> 

    http.does createServer: -> 
    done()

```

It uses mocha's JSON diff to display failure to call the function.

```json

      actual expected
      
      1 | {
      2 |   "1": {
      3 |     "FuctionExpectations": {
      4 |       "Object.createServer()": {
      5 |         "was called": truefalse ,
      6 |       }
      7 |     }
      8 |   }
      9 | }

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

**PENDING** You may have noticed that `MyServer` was also injected in the previous example.

* The injector recurses `./lib` for the specified module.
    * TODO: opts here
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

**PENDING** It supports injection of non-js-eval-able module names or cases where the local module search fails


```coffee

ipso = require 'ipso'
ipso.configure
    modules: 
        ...
        engine: 
            require: 'engine.io'
        Proxy:
            require: './lib/proxy/server'
        Core:
            require: './lib/core/server'
        ...

...
    
    it 'can inject by config', ipso (done, engine, Proxy, Core) -> 

        #
        # ...
        #

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

* IMPORTANT 
    * In these cases the test will timeout if the stub or mock was not called as expected. 
    * (pending tighter integration with mocha)
        * There will be no report of `http.createServer()` having not been called. 
        * `ipso` currently has no way to learn of the timeout.
            * Therefore it cannot reset the module (remove the stubs).
            * This is only a problem if the module is used in other tests without injection (ie. per having also been 'required' onto the global scope)

Previous stubs are flushed from **ALL** modules at **EVERY** injection
    
* this may be temporary (pending tighter integration with mocha)

```coffee
    
    beforeEach ipso (done, http) -> 

        http.does createServer: -> 'mock server'
        done()

    it 'no longer has the stub in this test', (done, http) -> 

        http.createServer().should.equal 'mock server' # fails

```

The successful approach is to set up ONLY the mocks in the hooks.

```coffee
    
    before -> 
        @mockServer = 
            _listen: (@port) => # have not tried this (@) => trick 
                                # in this particualt context yet...
            address: ->
            close: ->

    it 'should only ever stub inside the tests', ipso (facto, http, MyServer) -> 

        http.does createServer: => @mockServer

        (new MyServer).start => 

            @port.should.equal something

            #
            # ... but i suspect it works
            # 

            facto()

```

It supports promises.

```coffee

it 'fails the test on the first rejection in the chain', ipso (done, Module) -> 

    Module.functionThatReturnsAPromise()

    .then -> Module.functionThatReturnsAPromise()
    .then -> Module.functionThatReturnsAPromise()
    .then -> Module.functionThatReturnsAPromise()
    .then -> done()

```

Ipso Facto

```coffee

it 'does many things to come', ipso (facto, ...) -> 

    facto[metathings]()

    #
    # facto() calls mocha's done() in the background
    #

```

What metathings? 

* well, ... (( a brief brainstorm suggested a Planet-sized Plethora of Possibility avidly awaits a plunge into **that** rabbit hole.


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
 lib/same/dirname/source_name.coffee
spec/same/dirname/source_name_spec.coffee
```
