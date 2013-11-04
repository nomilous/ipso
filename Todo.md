* 0.0.10 
    * prototype stubs
    * local module injection from process.cwd()/lib/**/* or process.cwd()/app/**/*
        * identified by CamelCase
        * recursor searces for **/camel_case.js
        * `ipso.config modules: engine: [name: 'engine.io' OR path: '..']` will inject into `ipso (engine) ->` 
            * solves for problem of recurse collision / modules with un-js-friendly names
        * each test start **will still remove all stubs** on objects injected into an ancestor scope
    * `(facto...` not required to activate spectator
        * `done( thing )` will calls `mocha.done(thing)` only if thing is error, otherwise sent to `facto()` and empty `done()`


* tighter integration with mocha (backed out, maybve later)
    * inline mocha 
        * no respawn on each test run
        * tests become debuggable (ipso [--debug-port --web-port] --inspect --mocha)
        * ipso --mocha --silent --all  (runs all tests, silently, exits with failCount)
        * accesss to runner.on '...' test events 
            * can then cleanup stubs properly
                * not that their should be any objects required onto global for stubs to be left laying about in...!  
            * IF all modules are directly into the tests
                * THEN 
                    * no cleanup is necessary
                    * tests can then easily become hotswap-able / post-able in from remote dev station
                    * assuming corresponding codediffs for the changerun are also posted in
                * AND 
                    * that opens ""VERY! BIG! POSSIBILITIES!"" -> facto()
        * options to flush ENTIRE module cache
            * at each suite start  
            * at each test start?? --flush-on [suite|test]
                * may stomp on preps in before hooks
                * unless hooks ONLY configure @mocks to be passed to .does for stubbing INSIDE tests
                    * which is the "APPROPRIATE WAY"
