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

            Got @vodka
            Got @olive

            Not @gin
            Got @gin  # BUG, this should cause fail


    Martini  = require 'martini'
    instance = new Martini


    instance.shake()
    try instance.stir()

