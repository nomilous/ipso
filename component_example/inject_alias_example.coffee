require('../lib/ipso').components (Vertex, ifStats) -> 

    #
    # TODO
    # 
    # * remove .does per mode
    #

    ifStats.start()

    Vertex.create.www

        routes:

            #
            # curl localhost:3000/ifStats/latest
            # curl localhost:3000/ifStats/config
            #

            ifStats: ifStats

