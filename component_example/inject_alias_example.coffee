require('../lib/ipso').components (ifStats) -> 

    ifStats.start().then -> 

        console.log ifStats.current()

