require('../lib/ipso').inject (facto, Vertex, ifStats) -> 

    ifStats.start()

    .then -> Vertex.create.www

        routes:

            #
            # curl localhost:3000/ifStats/latest
            # curl localhost:3000/ifStats/config
            #

            ifStats: ifStats

    .then -> 

