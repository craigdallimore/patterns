chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

assert = chai.assert
expect = chai.expect
should = chai.should()
chai.use sinonChai

patterns = require './patterns.js'

suite 'Patterns', ->

    ###
    suite 'singleton', ->

        Singleton = patterns.Singleton
        instance1 = {}
        instance2 = {}

        before ->
            instance1 = new Singleton()
            instance2 = new Singleton()

        test 'should be the same object in different instances', ->

            bool = (instance1 == instance2)

            # instance1.should.equal instance2
            bool.should.be.true

        test 'should not have a public "instance" property on the constructor', ->

            Singleton.should.not.have.property 'instance'

        test 'should be able to be augmented, like a normal object', ->

            instance1 = new Singleton()
            Singleton.prototype.bar = 'baz'
            instance2 = new Singleton()

            instance1.should.have.property 'bar'
            instance2.should.have.property 'bar'

        test 'should correctly identify its constructor', ->

            instance1.should.be.an.instanceof Singleton
            instance2.should.be.an.instanceof Singleton
    ###

    suite 'Factory', ->

        shipyard = patterns.ShipFactory

        test 'requires a type', ->
            build = shipyard.build
            expect(build).to.throw /Type required/

        test 'can create objects', ->
            fighter = shipyard.build 'fighter'
            fighter.should.be.an 'object'

        test 'will create different kinds of objects based on the type supplied', ->
            fighter = shipyard.build 'fighter'
            drone = shipyard.build 'drone'

            fighter.should.have.property 'speed'
            fighter.getSpeed().should.equal 15

            drone.should.have.property 'speed'
            drone.getSpeed().should.equal 10

    suite 'Iterator', ->

        iterator = patterns.Iterator

        test 'has a "next" method', ->
            iterator.should.have.property 'next'
            iterator.next.should.be.a 'function'

        test '... which returns the next item', ->
            nextItem = iterator.next()
            nextItem.should.be.an 'object'
            nextItem.name.should.equal 'Sean Larsson'
            nextItem = iterator.next()
            nextItem.name.should.equal 'James Harth'

        test 'has a "hasNext" method', ->
            iterator.should.have.property 'hasNext'
            iterator.hasNext.should.be.a 'function'

        test '... which returns true if there is a next item', ->
            hasNext = iterator.hasNext()
            hasNext.should.equal true
        test '... and which returns false if there is not', ->
            iterator.next()
            iterator.next()
            hasNext = iterator.hasNext()
            hasNext.should.equal false

        test 'has a "current" method', ->
            iterator.should.have.property 'current'
            iterator.current.should.be.a 'function'

        test '... which returns null if there is no next item', ->
            next = iterator.next()
            expect(next).to.equal null

        test 'has a "rewind" method', ->
            iterator.should.have.property 'rewind'
            iterator.rewind.should.be.a 'function'

        test 'can rewind to the first item', ->
            iterator.rewind()
            first = iterator.current()
            first.should.be.an 'object'
            first.name.should.equal 'Sean Larsson'

        test 'will not advance the index using the "current" method', ->
            first = iterator.current()
            first.should.be.an 'object'
            first.name.should.equal 'Sean Larsson'

        test 'does not expose it\'s data for external manipulation', ->
            iterator.should.not.have.property 'data'

    suite 'Decorator', ->

        cake = null
        decorator = patterns.Decorator

        setup ->
            cake = decorator.makeCake()
        teardown ->
            cake = null

        test 'can tweak an object at runtime', ->
            cake.should.be.an.object
            expect(cake.getSugar()).to.equal '300g'

            cake.should.have.property 'decorate'
            cake.decorate 'frosting'
            expect(cake.getSugar()).to.equal '400g'

        test 'throws an error if an incorrect decorator is used', ->
            badDecoration = ->
                cake.decorate 'mustard'
            expect(badDecoration).to.throw Error

        test 'permits decorations to be removed', ->
            cake.getSugar().should.equal '300g'
            cake.decorate 'frosting'
            cake.decorate 'sprinkles'
            cake.getSugar().should.equal '450g'
            cake.unDecorate 'frosting'
            cake.getSugar().should.equal '350g'

        test 'only permits a decorator to be added once', ->
            cake.getSugar().should.equal '300g'
            cake.decorate 'frosting'
            cake.getSugar().should.equal '400g'
            cake.decorate 'frosting'
            cake.getSugar().should.equal '400g'

    suite 'Strategy', ->

        ender = null
        battlePlan = null
        strategy = patterns.Strategy
        setup ->
            ender = strategy.spawnGeneral()

        test 'permits an algorithm to be chosen at runtime', ->
            ender.should.be.an.object
            ender.should.have.property 'setStrategy'
            ender.setStrategy.should.be.a 'function'
            ender.should.have.property 'wageWar'
            ender.wageWar.should.be.a 'function'

            battlePlan = new strategy.Pincer()
            ender.setStrategy battlePlan
            expect(ender.wageWar()).to.equal 'devastating pincer attack!'

            peacePlan = new strategy.Diplomacy()
            ender.setStrategy peacePlan
            expect(ender.wageWar()).to.equal 'amicable friendship'

        test 'requires a strategy to be set', ->
            unplannedMove = ->
                ender.wageWar()
            expect(unplannedMove).to.throw /No strategy set/

        test 'requires a valid strategy', ->
            unlikelyRuse = ->
                ender.setStrategy 'surrender'
            expect(unlikelyRuse).to.throw Error

    suite 'Facade', ->

        facade = patterns.Facade
        wizard = null
        enchanter = null
        mage1 = null
        mage2 = null
        MageFacade = facade.MageFacade

        setup ->
            wizard = new facade.Wizard 'Mithrandir'
            enchanter = new facade.Enchanter 'Tim'

        test 'provides a common interface to multiple objects', ->
            wizard.should.be.an 'object'
            enchanter.should.be.an 'object'
            mage1 = new MageFacade wizard
            mage2 = new MageFacade enchanter
            expect(mage1.invoke('healing')).to.equal 'Mithrandir cast healing'
            expect(mage2.invoke('fireball')).to.equal 'Tim enchanted fireball'

    suite 'Proxy', ->

        proxy = patterns.Proxy

        stockKeeper = new proxy.StockKeeper()
        bookKeeper = new proxy.BookKeeper stockKeeper

        spy = sinon.spy stockKeeper, 'countStock'

        test 'enables one object to trigger an operation on another subject', (done) ->

            bookKeeper.getInventory (stock) ->
                expect(stock).to.equal '300 units'
                done()

        test 'masks or caches results from expensive operations', (done) ->

            bookKeeper.getInventory (stock) ->
                expect(stock).to.equal '300 units'
                spy.should.have.been.calledOnce
                done()

    suite 'Adapter', ->

        adapter = patterns.Adapter
        legacyDVR = new adapter.LegacyDVR()
        modernDVR = new adapter.ModernDVR()
        LegacyAdapter = adapter.LegacyAdapter
        DVRController = adapter.DVRController
        dvrcon = null
        legacyAdapter = null


        test 'is not required with compatible interfaces', ->
            dvrcon = new DVRController modernDVR
            dvrcon.startPlayback().should.equal 'started playback'
            dvrcon.stopPlayback().should.equal 'stopped playback'

        test 'is required when an interface is not compatible with its controller', ->
            dvrcon = new DVRController legacyDVR
            startFn = dvrcon.startPlayback
            stopFn = dvrcon.stopPlayback
            expect(startFn).to.throw Error
            expect(stopFn).to.throw Error

        test 'provides a compatibility layer', ->
            legacyAdapter = new LegacyAdapter legacyDVR
            dvrcon = new DVRController legacyAdapter
            dvrcon.startPlayback().should.equal 'started playback'
            dvrcon.stopPlayback().should.equal 'stopped playback'

    suite 'Composite', ->

        composite = patterns.Composite

        test 'should produce \'Node\' objects', ->
            node = new composite.Node 'TestNode'
            node.should.be.an 'object'
            node.should.have.property 'addChild'

        test 'Nodes can have names', ->
            node = new composite.Node 'TestNode'
            node.should.have.property 'sayName'
            expect(node.sayName()).to.equal 'Node:TestNode'

        test 'Nodes without names will instead call their children\'s names', ->
            parent =    new composite.Node
            child =     new composite.Node 'child'
            spy =       sinon.spy child, 'sayName'

            parent.addChild child
            parent.sayName()

            spy.should.have.been.calledOnce

        test 'Calling \'sayName\' on a node will recursively call it on all children', ->
            grandParent =   new composite.Node
            uncle =         new composite.Node
            aunt =          new composite.Node
            cousin1 =       new composite.Node 'C1'
            cousin2 =       new composite.Node 'C2'
            cousin3 =       new composite.Node 'C3'
            cousin4 =       new composite.Node 'C4'
            spy1 =          sinon.spy cousin1, 'sayName'
            spy2 =          sinon.spy cousin2, 'sayName'
            spy3 =          sinon.spy cousin3, 'sayName'
            spy4 =          sinon.spy cousin4, 'sayName'
            uncle.addChild cousin1
            uncle.addChild cousin2
            aunt.addChild cousin3
            aunt.addChild cousin4
            grandParent.addChild uncle
            grandParent.addChild aunt
            grandParent.sayName()
            aunt.sayName()
            spy1.should.have.been.calledOnce
            spy2.should.have.been.calledOnce
            spy3.should.have.been.calledTwice
            spy4.should.have.been.calledTwice

    suite 'Bridge', ->
        bridge = patterns.Bridge

        test 'A human body can be controlled by a human brain', ->
            body = new bridge.Body()
            mind = new bridge.HumanMind(body)
            expect(mind.moveForward()).to.equal 'BODY is moving forward with a speed of 5'

        test 'A human body can be controlled by a zombie mind', ->
            body = new bridge.Body()
            zombineMind = new bridge.ZombieMind(body)
            expect(zombineMind.shamble()).to.equal 'BODY is shambling forward with a speed of 2'

    suite 'Command', ->
        command = patterns.Command
        grunt = null

        setup ->
            grunt = new command.Grunt()


        test 'A grunt can lift up, carry and drop items', ->
            grunt.should.have.property 'lift'
            grunt.should.have.property 'walk'
            grunt.should.have.property 'drop'

            liftSpy = sinon.spy grunt, 'lift'
            walkSpy = sinon.spy grunt, 'walk'
            dropSpy = sinon.spy grunt, 'drop'

            expect(grunt.lift('box')).to.equal 'Grunt lifted an item: box'
            liftSpy.should.have.been.calledOnce

            expect(grunt.walk('stack')).to.equal 'Grunt walked to destination: stack'
            walkSpy.should.have.been.calledOnce

            expect(grunt.drop('box')).to.equal 'Grunt dropped an item: box'
            dropSpy.should.have.been.calledOnce

        test 'A grunt can do all that at once', ->
            grunt.should.have.property 'execute'

            liftSpy = sinon.spy grunt, 'lift'
            walkSpy = sinon.spy grunt, 'walk'
            dropSpy = sinon.spy grunt, 'drop'

            grunt.execute('box', 'stack');

            liftSpy.should.have.been.calledOnce
            walkSpy.should.have.been.calledOnce
            dropSpy.should.have.been.calledOnce


### TODO
    suite 'FlyWeight', ->
    suite 'Mediator', ->
    suite 'Observer', ->
###
