### NO FLUSH ###

### not in use ###

#
# global test event proxy
# -----------------------
#

{EventEmitter} = require 'events'
module.exports = emitter = new EventEmitter

#
# create tester
# ------------- 
#

Mocha = require 'mocha'

module.exports.create = (opts) -> 

    mocha = new Mocha reporter: (runner) -> 

        ###
        
           from: mocha/lib/runner.js
        
           Events:
           
             - `start`  execution started
             - `end`  execution complete
             - `suite`  (suite) test suite execution started
             - `suite end`  (suite) all tests (and sub-suites) have finished
             - `test`  (test) test execution started
             - `test end`  (test) test completed
             - `hook`  (hook) hook execution started
             - `hook end`  (hook) hook complete
             - `pass`  (test) test passed
             - `fail`  (test, err) test failed
             - `pending`  (test) test pending
        
        ###

        for event in ['start','end','suite','suite end','test','test end',
                      'hook','hook end','pass','fail','pending']

            do (event) -> runner.on event, (data...) -> 

                ## THIS IN THE TEST RUNNER

                emitter.emit 'spec_event', 

                    source: 'mocha'
                    event: event
                    data:  data


        #
        # Mocha.reporters[ opts.reporter || 'Dot']
        # 
        # * having diffulties including another reporter
        # * much is lost if i can't do that
        #

    return api = 

        run: (files, callback) -> 

            mocha.addFile file for file in files
            mocha.run callback
