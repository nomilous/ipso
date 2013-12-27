require('../lib/ipso').inject (facto, Vertex, ifStats) -> 

    #
    # component install nomilous/linux-if-stats -f
    # component install nomilous/vertex@develop -f
    # 

    ifStats.start()

    .then -> Vertex.create.www

        routes:

            #
            # curl localhost:3000/ifStats/latest
            # curl localhost:3000/ifStats/config
            #

            ifStats: ifStats

    .then -> 

