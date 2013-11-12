
**PARTIALLY PENDING** It can `$save( templateName )` newly written stubs into `./src/**/*` as "first draft"

still untidy implementation

```coffee

it 'can detect a non existant LocalModule being injected', ipso (done, NewModuleName) -> 

    #
    # when ./lib/**/* contains no file called new_module_name.coffee
    # ------ === ---------------------------------------------------
    # 
    # * a standin module is injected
    # * a warning is displayed
    # * NewModuleName.does() can still be used to define stubs
    # * NewModuleName.$save( 'templateName' ) can use template
    #   defined in ~/.ipso/templates/templateName and the function stubs to 
    #   create the new source file at ./src/relative/path/new_module_name.coffee
    #                                   ===
    # 

    NewModuleName.does 

        function1: ->
        function2: ->

    NewModuleName.$save 'factory'


```

creates (using `~/.ipso/templates/factory`)

```coffee

lastInstance = undefined
module.exports = ->

    lastInstance = local = 

        function1: ->

        function2: ->


    return api = 
        function1: local.function1
        function2: local.function2

module.exports._test = -> lastInstance


```

After creating the next test will fail with 
```
  1) MissingModule "after all" hook:
     TypeError: Object function () {
  var api, local;
  lastInstance = local = {
    function1: function() {},
    function2: function() {}
  };
  return api = {
    function1: local.function1,
    function2: local.function2
  };
} has no method '$save'

```

because $save() no longer exists on the object being injected

it uses IPSO_SRC env variable in target path assembly

