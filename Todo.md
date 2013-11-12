* 0.0.10 
    * local module injection from process.cwd()/lib/**/* or process.cwd()/app/**/*
        * identified by CamelCase
        * recursor searces for **/camel_case.js
        * `ipso.config modules: engine: [name: 'engine.io' OR path: '..']` will inject into `ipso (engine) ->` 
            * solves for problem of recurse collision / modules with un-js-friendly names
        * each test start **will still remove all stubs** on objects injected into an ancestor scope
    * `(facto...` not required to activate spectator
        * `done( thing )` will calls `mocha.done(thing)` only if thing is error, otherwise sent to `facto()` and empty `done()`

    * added ipso.tag for tagged injection
    * mocks for "deeper" function expectation

