require('nez').realize 'SpecRun', (SpecRun, test, context) -> 

    context 'in CONTEXT', (does) ->

        does 'an EXPECTATION', (done) ->

            test done
