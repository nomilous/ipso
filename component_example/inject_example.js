require('../lib/ipso').components( 

    function(emitter) {

        e = new emitter

        e.on('eventname', function(payload) {
            console.log({received: payload});
        });

        e.emit('eventname', 'DATA');

    }
);
