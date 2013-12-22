{ipso, tag} = require 'ipso'

describe 'Components', -> 

    it """

        * bridges installed components for serverside access via require (by name)

        * it loads additional config, specifically, the injection alias/tag for components
          that cannot be injected directly because of dashes and or dots in their names

    """, ->



    before ipso ->  

        tag 

            does: require('does')._test()


    it 'sets does mode to bridge', 

        ipso (does, fs) -> 

            does.does mode: (mode) -> mode.should.equal 'bridge'
            fs.does readdirSync: -> []
            ipso.components()


    xit 'uses component.inject.alias to predefine injection tag', 

        ipso (does, fs) -> 

            #
            # mock an installed compoent
            #

            fs.does readdirSync: -> ['username-mock-component']
            fs.does readFileSync: (filename) -> 

                if filename.match /username-mock-component\/component.json$/

                    return JSON.stringify

                        name: 'mock-component'
                        main: 'index.js'
                        inject: alias: 'tagname'


            ipso.components()
            console.log does

            #
            # damn this stuff is hard to test
            #

