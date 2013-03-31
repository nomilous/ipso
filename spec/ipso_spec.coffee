require('nez').realize 'Ipso', (Ipso, test, it, should) ->

    it 'exports Validator', (done) -> 

        Ipso.Validator.should.equal require '../lib/Validator'
        test done

    it 'exports SpecRun', (done) -> 

        Ipso.SpecRun.should.equal require '../lib/validators/spec_run'
        test done
