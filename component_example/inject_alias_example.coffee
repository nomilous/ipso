

#
# quick hack round some known issues
#

{tag, define, components} = require 'ipso'
define 'engine.io': -> 
components()
define ifStats: -> require 'linux-if-stats'





require('../lib/ipso').components (vertex, ifStats) -> 

    #
    # TODO
    # 
    # * consider vertex.create.www()
    # * consider www.routes instead of www.root as root of tree
    # * rename ifStats.current to something less obtuse
    # * consider ifStats.current as property to avail from uptree without the resursor walk
    # 

    ifStats.start()

    vertex.create 

        www:

            listen: port: 3000
            allowRoot: true
            root: 
                network:
                    interfaces: ifStats

                    #
                    # curl localhost:3000/network/interfaces/current
                    #
