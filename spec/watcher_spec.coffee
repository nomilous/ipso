hound   = require 'hound'
should  = require 'should'
{watcher} = require '../lib/watcher' 

describe 'watch', -> 

    it 'watches specified paths', (done) -> 

        hound.watch = (path) -> 
            path.should.match /\/PATH/
            on: (event, handlr) -> 
                handlr.should.equal listen
                done()

        watcher
            path: '/PATH'
            handler: change: listen = ->


