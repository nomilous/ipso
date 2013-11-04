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

It creates a capacity to stub functions on injected modules.

```coffee

it 'creates an http server', ipso (done, http) -> 

    http.does createServer: -> 
    done()

```

It uses mocha's JSON diff to display failure.

```json

      actual expected <----- with colours
      
      1 | {
      2 |   "1": {
      3 |     "FuctionExpectations": {
      4 |       "Object.createServer()": {
      5 |         "was called": truefalse , <----- with colours
      6 |       }
      7 |     }
      8 |   }
      9 | }

```

The stub can return a mock.

```coffee

MyServer = require '../lib/my_server'

it 'creates an http server and listens at opts.port', ipso (done, http) -> 

    http.does 
        createServer: -> 
            listen: (port) -> 
                port.should.equal 3000

    MyServer.listen port: 3000
    done()

```




cli
---

There is a cli. 

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

It can quickly start up a node-inspector session on a v8 debugger socket.

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



```



















































































```


### mode nodule injection

```coffee
# thing = require 'thing'

it 'does something for which it needs the thing', ipso (done, thing) -> 

    #
    # then, as usual...
    #

    thing with: 'stuff', (err) -> 

        err.message.should.equal 'incorrect stuff'
        done()

```

* `done` can only be injected at position1
* it must literally be called ""done""
* there is currently no way to inject node modules with-dashes.or dots in their names.
* injecting a module that is not already installed will not automatically install it in the 'background' and conveniently update the package file, yet.


### spectateable mode nodule injection

```coffee

it 'starts http listening at config.api.port', ipso (facto, http) -> 

    http.does 

        #
        # create active stub(s) on http object
        #

        createServer: ->

            #
            # stubbed function returns "mock" server that defines listen()
            #

            listen: (port) -> 

                #
                # test is resolved if **something** calls listen
                #

                port.should.equal 2999
                facto()


    server api: port: process.env.API_PORT

```

* test arg1 must literally be called ""facto""
* `thing.does _function: ->` creates as spy on `thing.function`
* BUG: stubbed module functions are not cleaned up in cases where tests timeout
* SHORTCOMING: function expectations only work correctly when created in `it()`s


### using promises

#### it solves the chain problem

These (↓) tests do not fail... Instead they timeout.

```coffee

it 'does something ...', (done) -> 

    functionThatReturnsAPromise().then -> 

        true.should.equal false
        done()

```

The problem is that `should` is throwing an [`AssertionError`](http://nodejs.org/api/assert.html) that is being caught by the promise handler instead of the `it()` function. This catch is a necessary component of the promise API - enabling `then()` chains to reject as designed.

One possible solution is to chain in the test...

```coffee

it 'does something ...', (done) -> 

    functionThatReturnsAPromise().then -> 

        true.should.equal false
        done()

    .then (->), done

    #
    # with the second done as the rejection handler, resulting in the throw being
    # passed to mocha's test resolver, causing the fail to be received by that 
    # alternative to it's regular catcher.
    #

```

ipso does the chain internally if the test returns a promise


```coffee

it 'fails without timeout', ipso (done) -> 

    functionThatReturnsAPromise().then -> 

        true.should.equal false
        done()

        #
        # Note: this will still timeout if functionThatReturnsAPromise() rejects 
        # TODO: it still times out on longer chains! grrr
        #

```

### `LocalNodule` injection

```coffee


```

