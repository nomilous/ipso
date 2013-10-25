require('nez').realize 'Validator', (Validator, test, it) -> 
    
    it 'defines validate()', (done) -> 

        (new Validator).validate.should.be.an.instanceof Function

        test done
