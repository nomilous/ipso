require('../lib/ipso').inject (Vertex, ifStats) -> 

    #
    # TODO
    # 
    # * remove .does per mode
    # * arg1 done or facto creates async without timeout
    # * MAYBE if the function returns a promise, throw on the reject
    #

    ifStats.start()

    Vertex.create.www

        routes:

            #
            # curl localhost:3000/ifStats/latest
            # curl localhost:3000/ifStats/config
            #

            ifStats: ifStats

