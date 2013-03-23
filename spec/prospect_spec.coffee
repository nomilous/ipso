require('nez').realize 'Prospect', (Prospect, test, context) -> 

    context 'extends Object', (to) -> 

        to 'define object.receive()', (done) -> 

            Object.prototype.receive.should.equal Prospect.validatable

            test done

