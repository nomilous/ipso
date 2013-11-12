{ipso, tag} = require '../lib/ipso'


describe 'Saver', -> 

    #
    # tag an instance of does to tet against
    #

    before ipso (done, does)  -> tag( does1: does() ).then done


    #
    # tag all functions on the save module for direct injection
    #

    before ipso (done, Saver) -> tag( Saver ).then done
                                        #
                                        # nice :)
                                        #
    


    context 'specLocation()', -> 

        it 'returns the calling spec location details', ipso (specLocation) ->

            specLocation().should.eql

                fileName: 'saver_spec.coffee'
                baseName: 'saver'
                specPath: 'spec'



    context 'save()', -> 


        it 'gets the entity record from does', ipso (does1, save) -> 

            does1.does get: (opts) -> opts.should.eql query: tag: 'ModuleName'
            save 'template', 'ModuleName', does1

            console.log TODO: 'only display functions with stubs / expectations in failure hash'
    

