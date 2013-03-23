require('nez').realize 'Must', (Must, test, context, should) -> 

    context 'extends Object', (to) -> 

        to 'define object.must()', (done) -> 

            Object.prototype.must.should.equal Must.necessity
            test done

