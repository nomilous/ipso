
describe 'Components', -> 

    it """

        * bridges installed components for serverside access via require (by name)

        * can inject (by name) components, node_modules and modules defined locally
          in ./lib and ./app

        * PENDING it supports additional config, specifically, the injection alias/tag 
          for components that cannot be injected directly because of dashes and or dots 
          in their names

    """, ->


    it 'sets mode to bridge in does'


    it 'calls the function at lastarg'


    it 'injects components into the function according to name'


    it 'injects components into the function with names from component.inject.alias'


    it 'uses component.inject.alias to define an additional require alias'

    