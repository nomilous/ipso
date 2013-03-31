module.exports = 
    
    #
    # **Export:** [Validator](validator.html)
    # **Inject:** `ipso:Validator`
    # 
    # This is the base class for defining a Validator
    #    

    Validator: require './validator'


    #
    # **Export:** [SpecRun](validators/spec_run.html)
    # **Inject:** `ipso:SpecRun`
    # **Uplink:** `eo:Develop`
    # 
    # Software Implementation Validation
    # 

    SpecRun: require './validators/spec_run'
