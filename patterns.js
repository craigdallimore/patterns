// Implementation of some classic design patterns in JavaScript
// Credit to Addy Osmani

/*!
 * Singleton
 * - For creating only one instance of a 'class'
 */
function Singleton() {

    // The cached instace
    var instance;

    // Rewrite the constructor
    Singleton = function Singleton() {
        return instance;
    };

    // Provide access to the prototype
    Singleton.prototype = this;

    // Create the new instance
    instance = new Singleton();

    // Reset the constructor pointer
    instance.constructor = Singleton;
    // Properties, methods
    instance.foo = 'bar';

    return instance;

}

exports.Singleton = Singleton;

/*!
 * Factory
 * - For creating objects of a type specified at runtime
 */
function ShipFactory() {

}

// Default ship
ShipFactory.prototype.speed = 5;
ShipFactory.prototype.getSpeed = function() {
    return this.speed;
};

// The build method
ShipFactory.build = function(type) {
    var newShip;

    if (!type) {
        throw {
            name: 'Error',
            message: 'Type required'
        };
    }
    if (typeof ShipFactory[type] !== 'function') {
        throw {
            name: 'Error',
            message: 'Invalid type'
        };
    }
    if (typeof ShipFactory[type].prototype.speed !== 'number') {
        // inherit from parent, once only
        ShipFactory[type].prototype = new ShipFactory();
    }
    return new ShipFactory[type]();

};
ShipFactory.fighter = function() {
    this.speed = 15;
};
ShipFactory.drone = function() {
    this.speed = 10;
};

exports.ShipFactory = ShipFactory;

/*!
 * Iterator
 * - For looping over / navigating a data structure
 */
var iterator = (function() {

    var data = [
        { team: 'Keas', name: 'Sean Larsson' },
        { team: 'Tuataras', name: 'James Harth' },
        { team: 'Bats', name: 'Hannah Berry' },
        { team: 'Wetas', name: 'Giles Fang' }
    ],
    index = 0,
    length = data.length;

    return {
        next: function() {
            if (this.hasNext()) {
                return data[index++];
            }
            return null;
        },
        hasNext: function() {
            return index < length;
        },
        current: function() {
            return data[index];
        },
        rewind: function() {
            index = 0;
        }
    };

}());

exports.Iterator = iterator;

/*!
 * Decorator
 * - For adjusting a target object by adding functionality from decorator objects
 */

exports.Decorator = {

    makeCake: function() {

        function Cake() {
            this.decorations = [];
            this.sugar =  300;
        }

        Cake.prototype.decorate = function decorate(decorator) {
            if (!Cake.decorators[decorator]) {
                throw new Error({
                    name: 'NotFoundError',
                    message: 'Decorator ' + decorator + ' does not exist'
                });
            }
            if (this.decorations.indexOf(decorator) === -1) {
                this.decorations.push(decorator);
            }
        };
        Cake.prototype.unDecorate = function unDecorate(decorator) {
            if (this.decorations.indexOf(decorator) > -1) {
                this.decorations = this.decorations.slice(this.decorations.indexOf(decorator, 1));
            }
        };
        Cake.prototype.getSugar = function getSugar() {
            var sugar = this.sugar;
            this.decorations.forEach(function(decoration) {
                sugar = Cake.decorators[decoration].getSugar(sugar);
            });
            return sugar + 'g';
        };

        Cake.decorators = {};
        Cake.decorators.frosting = {
            getSugar: function getSugar(sugar) {
                return sugar + 100;
            }
        };
        Cake.decorators.sprinkles = {
            getSugar: function getSugar(sugar) {
                return sugar + 50;
            }
        };


        return new Cake();

    }

};

/*!
 * Strategy
 * - For swapping an algorithm at runtime
 */

exports.Strategy = {

    spawnGeneral: function() {

        function General() {
        }
        General.prototype.setStrategy = function(strategy) {
            if (typeof strategy !== 'object') {
                throw new Error('Strategy not defined');
            }
            this.strategy = strategy;
        };
        General.prototype.wageWar = function() {
            if (!this.strategy) {
                throw new Error('No strategy set');
            }
            return this.strategy.enact();
        };

        return new General();
    },

    Pincer: function Pincer() {
        this.enact = function() {
            return 'devastating pincer attack!';
        };
    },

    Diplomacy: function Diplomacy() {
        this.enact = function() {
            return 'amicable friendship';
        };
    }


};

/*!
 * Facade
 * - Provides a common interface for two similar but non-identical methods
 */
var facade = (function() {

    function Wizard(name) {
        this.name = name;
    }
    Wizard.prototype.cast = function cast(spell) {
        return this.name + ' cast ' + spell;
    };

    function Enchanter(name) {
        this.name = name;
    }
    Enchanter.prototype.cast = function enchant(spell) {
        return this.name + ' enchanted ' + spell;
    };
    function MageFacade(mage) {
        this.mage = mage;
    }
    MageFacade.prototype.invoke = function invoke(spell) {
        var mage = this.mage;

        if (typeof mage.cast !== 'undefined') {
            return mage.cast(spell);
        }
        if (typeof mage.enchant !== 'undefined') {
            return mage.enchant(spell);
        }

    };

    return {
        Wizard: Wizard,
        Enchanter: Enchanter,
        MageFacade: MageFacade
    };

}());


exports.Facade = facade;


/*!
 * Proxy
 * - One object acts as an interface to another object, perhaps to mask expensive operations
 * - In this example, there is a book keeper and stock keeper. The book keeper only requests
 *   the expensive stock counting operation from the stock keeper when it doesn't know how
 *   much stock there is.
 */

var proxy = (function() {

    function StockKeeper() {}
    StockKeeper.prototype.countStock = function(callback) {
        setTimeout(function() {
            callback('300 units');
        }, 150);
    };

    function BookKeeper(stockKeeper) {
        this.stockKeeper = stockKeeper;
        this.stock = null;
    }
    BookKeeper.prototype.getInventory = function(callback) {

        var bookKeeper = this;

        if (this.stock) {
            return callback(this.stock);
        }
        this.stockKeeper.countStock(function(stock) {
            callback(stock);
            bookKeeper.stock = stock;
        });
    };

    return {
        StockKeeper: StockKeeper,
        BookKeeper: BookKeeper
    };


}());


exports.Proxy = proxy;

/*!
 * Adapter
 * - for translating one interface to another
 */
var adapter = (function() {

    function LegacyDVR() {}
    LegacyDVR.prototype.play = function play() {
        return 'playing';
    };
    LegacyDVR.prototype.pause = function pause() {
        return 'paused';
    };


    function ModernDVR() {}
    ModernDVR.prototype.start = function start() {
        return 'started playback';
    };
    ModernDVR.prototype.halt = function halt() {
        return 'stopped playback';
    };

    function DVRController( DVR ) {
        this.DVR = DVR;
    }
    DVRController.prototype.startPlayback = function() {
        if(!this.DVR.start) throw new Error('incompatible');
        return this.DVR.start();
    };
    DVRController.prototype.stopPlayback = function() {
        if(!this.DVR.halt) throw new Error('incompatible');
        return this.DVR.halt();
    };

    function LegacyAdapter( DVR ) {
        this.DVR = DVR;
    }
    LegacyAdapter.prototype.start = function start() {
        this.DVR.play();
        return 'started playback';
    };
    LegacyAdapter.prototype.halt = function start() {
        this.DVR.pause();
        return 'stopped playback';
    };

    return {
        LegacyDVR: LegacyDVR,
        ModernDVR: ModernDVR,
        DVRController: DVRController,
        LegacyAdapter: LegacyAdapter
    };

}());


exports.Adapter = adapter;

/*!
 * Composite
 * - Enable a group of similar objects to be managed in the same way
 *   as a single instance of the object.
 */

var composite = (function() {

    function Node( name ) {
        this.name = name || null;
        this.children = [];
    }
    Node.prototype = {
        addChild: function addChild(child) {
            this.children.push(child);
        },
        sayName: function sayName() {
            if (this.name) {
                return 'Node:' + this.name;
            } else {
                this.traverse('sayName');
            }
        },
        traverse: function traverse(fn) {
            this.children.map(function(child) {
                child[fn]();
            });
        }
    };




    return {
        Node: Node
    };

}());

exports.Composite = composite;

/*!
 * Bridge
 */

/*!
 * Command
 * -
 */

/*!
 * Mediator
 * -
 */

/*!
 * Observer / PubSub / Custom Events
 * -
 */


