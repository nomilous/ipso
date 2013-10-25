ipso
====

For testing with mocha 
----------------------

### not using promises

later... 


### using promises

#### there's a problem

These (↓) tests do not fail... Instead they timeout.

```coffee

it 'should ...', (done) -> 

    functionThatReturnsAPromise().then -> 

        true.should.equal false
        done()

```

The problem is that `should` is throwing an `[AssertionError](http://nodejs.org/api/assert.html)` that is being caught by the promise handler. This catch is a necessary component of the promise API - enabling `then()` chains to reject as designed.

One possible solution is to chain in the test...

```coffee

it 'should ...', (done) -> 

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

...but i don't like that, and it occurred to me a function decorator could be used to ""proxy"" the `done()` into the second `then()`

```coffee

{facto} = require 'ipso'

it 'should ...', facto (done) -> 

    functionThatReturnsAPromise().then -> 

        true.should.equal false
        done()

```


### spy injection

later...

