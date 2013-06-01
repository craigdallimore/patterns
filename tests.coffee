chai = require './chai.js'
assert = chai.assert
expect = chai.expect
should = chai.should()

patterns = require './patterns.js'

describe 'Patterns', ->

    ###
    describe 'singleton', ->

        Singleton = patterns.Singleton
        instance1 = {}
        instance2 = {}

        before ->
            instance1 = new Singleton()
            instance2 = new Singleton()

        it 'should be the same object in different instances', ->

            bool = (instance1 == instance2)

            # instance1.should.equal instance2
            bool.should.be.true

        it 'should not have a public "instance" property on the constructor', ->

            Singleton.should.not.have.property 'instance'

        it 'should be able to be augmented, like a normal object', ->

            instance1 = new Singleton()
            Singleton.prototype.bar = 'baz'
            instance2 = new Singleton()

            instance1.should.have.property 'bar'
            instance2.should.have.property 'bar'

        it 'should correctly identify its constructor', ->

            instance1.should.be.an.instanceof Singleton
            instance2.should.be.an.instanceof Singleton
    ###

    describe 'Factory', ->

        shipyard = patterns.ShipFactory

        it 'requires a type', ->
            build = shipyard.build
            expect(build).to.throw /Type required/

        it 'can create objects', ->
            fighter = shipyard.build 'fighter'
            fighter.should.be.an 'object'

        it 'will create different kinds of objects based on the type supplied', ->
            fighter = shipyard.build 'fighter'
            drone = shipyard.build 'drone'

            fighter.should.have.property 'speed'
            fighter.getSpeed().should.equal 15

            drone.should.have.property 'speed'
            drone.getSpeed().should.equal 10

    describe 'Iterator', ->

        iterator = patterns.Iterator

        it 'has a "next" method', ->
            iterator.should.have.property 'next'
            iterator.next.should.be.a 'function'

        it '... which returns the next item', ->
            nextItem = iterator.next()
            nextItem.should.be.an 'object'
            nextItem.name.should.equal 'Sean Larsson'
            nextItem = iterator.next()
            nextItem.name.should.equal 'James Harth'

        it 'has a "hasNext" method', ->
            iterator.should.have.property 'hasNext'
            iterator.hasNext.should.be.a 'function'

        it '... which returns true if there is a next item', ->
            hasNext = iterator.hasNext()
            hasNext.should.equal true
        it '... and which returns false if there is not', ->
            iterator.next()
            iterator.next()
            hasNext = iterator.hasNext()
            hasNext.should.equal false

        it 'has a "current" method', ->
            iterator.should.have.property 'current'
            iterator.current.should.be.a 'function'

        it '... which returns null if there is no next item', ->
            next = iterator.next()
            expect(next).to.equal null

        it 'has a "rewind" method', ->
            iterator.should.have.property 'rewind'
            iterator.rewind.should.be.a 'function'

        it 'can rewind to the first item', ->
            iterator.rewind()
            first = iterator.current()
            first.should.be.an 'object'
            first.name.should.equal 'Sean Larsson'

        it 'will not advance the index using the "current" method', ->
            first = iterator.current()
            first.should.be.an 'object'
            first.name.should.equal 'Sean Larsson'

        it 'does not expose it\'s data for external manipulation', ->
            iterator.should.not.have.property 'data'

    describe 'Decorator', ->

        cake = null
        decorator = patterns.Decorator

        beforeEach ->
            cake = decorator.makeCake()
        afterEach ->
            cake = null

        it 'can tweak an object at runtime', ->
            cake.should.be.an.object
            expect(cake.getSugar()).to.equal '300g'

            cake.should.have.property 'decorate'
            cake.decorate 'frosting'
            expect(cake.getSugar()).to.equal '400g'

        it 'throws an error if an incorrect decorator is used', ->
            badDecoration = ->
                cake.decorate 'mustard'
            expect(badDecoration).to.throw Error

        it 'permits decorations to be removed', ->
            cake.getSugar().should.equal '300g'
            cake.decorate 'frosting'
            cake.decorate 'sprinkles'
            cake.getSugar().should.equal '450g'
            cake.unDecorate 'frosting'
            cake.getSugar().should.equal '350g'

        it 'only permits a decorator to be added once', ->
            cake.getSugar().should.equal '300g'
            cake.decorate 'frosting'
            cake.getSugar().should.equal '400g'
            cake.decorate 'frosting'
            cake.getSugar().should.equal '400g'

    describe 'Strategy', ->

        ender = null
        battlePlan = null
        strategy = patterns.Strategy
        beforeEach ->
            ender = strategy.spawnGeneral()

        it 'permits an algorithm to be chosen at runtime', ->
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

        it 'requires a strategy to be set', ->
            unplannedMove = ->
                ender.wageWar()
            expect(unplannedMove).to.throw /No strategy set/

        it 'requires a valid strategy', ->
            unlikelyRuse = ->
                ender.setStrategy 'surrender'
            expect(unlikelyRuse).to.throw Error
### TODO
    describe 'Facade', ->
    describe 'Proxy', ->
    describe 'Mediator', ->
    describe 'Observer', ->
###
