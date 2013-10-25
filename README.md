`npm install ipso` 0.0.2 [license](./license)

**experimental/unstable** api changes will still occur (without deprecation warnings)

A test decorator. (for [mocha](https://github.com/visionmedia/mocha))


ipso
====

```coffee
ipso = require 'ipso'

it 'does something', ipso (done) -> 

    #
    # as usual
    #
    
    done()

```

### node module injection

```coffee
# thing = require 'thing'

it 'does something and needs the thing', ipso (done, thing) -> 

    #
    # then, as usual...
    #

    thing with: 'stuff', (err) -> 

        err.message.should.equal 'incorrect stuff'
        done()

```


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

ipso internally ""proxies"" the `done()` into a second `then()` if the test returns a promise.

```coffee

it 'fails without timeout', ipso (done) -> 

    functionThatReturnsAPromise().then -> 

        true.should.equal false
        done()

        #
        # Note: this will still timeout if functionThatReturnsAPromise() rejects 
        # 
        #

```

### local ModuleInjection 

later...


### active stubs / spy injection

later...

* set function and property expectations (rspec style)


### p.s. 

You might be inclined, for amuzement sake, to do this: 

```coffee

it 'does something ...', ipso (facto) -> 

    #
    # ... me too :)
    # 

    # 
    # Note: facto() isn't exactly done()
    #

```
