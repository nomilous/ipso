

catch22
=======

Combining runtime and spectime injection are mutually exclusive. `ipso.inject` will move elsewhere.



### injection example

```js
require('ipso').inject( function(emitter) {

    e = new emitter
    e.on('eventname', function(payload) {
        console.log({received: payload});
    });
    e.emit('eventname', 'DATA');

});

```

```coffee
require('ipso').inject (emitter) -> 

    #
    # components (and node_modules) are injected per the function argument names
    #

    e = new emitter
    e.on   'eventname', (payload) -> console.log received: payload
    e.emit 'eventname', 'DATA'

```

* There may be issues with component name collision
* **Components with dots and dashes in their names cannot be injected this simply**
* TODO: Solution is not yet clear



### injection example using `component.inject.alias`

```
component install nomilous/vertex@develop -f

coffee inject_alias_example.coffee
```

When the `component.json` file contains the **custom** property

```json
{
    "inject": {
        "alias": "Vertex"
    },
}
```

Then the component becomes injectable (or requirable) by that name

```coffee

require('ipso').inject (Vertex) -> 

    Vertex.create.www routes: path: {}


```




Further Ideas
-------------




### **MAYBE** - just-in-time async injection

* Something like the following (still mulling)
* Installs the necessary components on first run

```coffee

require('ipso').components

    Config:

        repo: 'company/knowledge-base'
        version: '0.1.2'
        remotes: [
            'https://user:pass@primary'
            'https://user:pass@fallback'
        ]

    Users:

        repo: 'nomilous/linux-users' # does not exist (yet)
        version: '0.1.2'

        #
        # remote default to github public components
        #

    Apt:

        repo: 'nomilous/ubuntu-apt' # does not exist (yet)


    (os, Config, Users, Apt) ->

        Config.refresh( hostname: os.hostname(), version: Config.cachedVersion )

        .then -> 

            Users.ensure( Config.users.present, Config.users.absent )

        .then -> 

            Apt.ensureSource( Config.apt.source )

        .then -> 

            #
            # et...
            #


        .then -> 

            #
            # ...cetera
            #

        .then( 

            success = -> 

                Config.report 

                    hostname: os.hostname()
                    status: 'ok'

            failure = (err) -> 

                Config.report 

                    hostname: os.hostname()
                    status: 'error'
                    error: err.stack

            # 
            # notify = (intermediate_step_result) -> Config.report ...
            # 
            # * not certain that the promise notify handle works at chain's tail
            #

        )

```

* possibly pointless, most of the above can be achieved with a component.json
* the just-in-time-ness is has risks
* the keyed list might be a nice solution to name collision tho


### See Also

* [vital](https://github.com/nomilous/vital) 

