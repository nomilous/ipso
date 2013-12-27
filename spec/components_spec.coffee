{components, inject} = require 'ipso'

describe 'Components', -> 

    before -> 

        @does = require('does')._test()


    it """

        * bridges installed components for serverside access via require (by name)

        * can inject (by name) components, node_modules and modules defined locally
          in ./lib and ./app

        * PENDING it supports additional config, specifically, the injection alias/tag 
          for components that cannot be injected directly because of dashes and or dots 
          in their names

    """, ->


    it 'sets mode to bridge in does', -> 

        components()
        @does.mode.should.equal 'bridge'


    it 'enables require by component name', -> 

        components()
        componentname = require 'componentname'
        componentname().should.equal 'FOR TESTING'


    it 'is also accessable at inject()', -> 

        components.should.equal inject


    it 'calls the function at lastarg', (done) -> 

        inject {}, -> done()


    it 'injects components into the function according to name', (done) -> 

        inject {}, {}, (componentname) -> 

            componentname().should.equal 'FOR TESTING'
            done()


    it 'injects components into the function with names from component.inject.alias'


    it 'uses component.inject.alias to define an additional require alias'

    