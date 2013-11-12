{specLocation, save} = require '../lib/saver'


describe 'Saver', -> 

    context 'getSpecLocation', -> 

        it 'returns the callign spec location details', ->

            specLocation().should.eql

                fileName: 'saver_spec.coffee'
                baseName: 'saver'
                specPath: 'spec'

