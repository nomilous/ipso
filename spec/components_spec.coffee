{ipso, tag} = require 'ipso'

describe 'Components', -> 

    it """

        * bridges installed components for serverside access via require (by name)

        * it loads additional config, specifically, the injection alias/tag for components
          that cannot be injected directly because of dashes and or dots in their names

    """, ->



    before ipso ->  

        tag 

            does: ipso.does 


    it 'sets does mode to bridge', 

        ipso (does, fs) -> 

            does.does mode: (mode) -> mode.should.equal 'bridge'
            fs.does readdirSync: -> []
            ipso.components()

