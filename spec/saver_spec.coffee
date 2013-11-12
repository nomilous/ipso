{ipso, tag, mock} = require '../lib/ipso'


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


        context 'with entity', -> 

            beforeEach ipso (does1, Saver) -> 

                entity = mock 'entity'
                does1.does get: (args...) -> args.pop() null, entity

                template = mock 'template'
                Saver.does load: -> template

               
            it 'loads template and passes entity to render', ipso (save, does1, entity, template) -> 


                template.does render: (e) -> e.is entity
                save 'templateName', 'ModuleName', does1


