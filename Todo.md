* 0.0.10 
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
    * does.spactate() on synchronous injection
    * `(facto...` not required to activate spectator
        * done( thing ) will call mocha.done only if error, otherwise sent to facto() and empty done()
