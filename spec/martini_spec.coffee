{ipso, tag, define, Mock} = require '../lib/ipso'

before ipso (should) -> 

    tag

        Got: should.exist
        Not: should.not.exist

    define 

        martini: -> Mock 'VodkaMartini'


it 'has the vodka and the olive', ipso (VodkaMartini, Got, Not) -> 

    VodkaMartini.with 

        olive: true

    .does

        constructor: -> @vodka = true
        shake: ->


    Martini  = require 'martini'
    instance = new Martini

    Got instance.vodka
    Got instance.olive
    Not instance.gin

    instance.shake()

    try instance.stir()

