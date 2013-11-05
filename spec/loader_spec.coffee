Loader = require '../lib/loader'
ipso   = require '../lib/ipso'

describe 'Loader', -> 

    it 'keeps original cwd', (done) -> 

        instance = Loader.create dir: 'DIR'
        Loader._test().dir.should.equal 'DIR'
        done()

    it 'can determine if a module starts with Uppercase', (done) -> 

        instance = Loader.create dir: 'DIR'
        Loader._test().upperCase('A').should.equal true
        Loader._test().upperCase('Z').should.equal true
        Loader._test().upperCase('a').should.equal false
        done()


    it 'loads node_modules if starting with lowercase', ipso (done) -> 

        instance = Loader.create dir: 'DIR'
        instance.loadModules ['http'], (http) -> 

            http.should.equal require 'http'
            done()

