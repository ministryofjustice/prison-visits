Array.prototype.forEachWithIndex = function(f) {
    for (var i = 0; i < this.length; i++) {
        f(this[i], i);
    }
}
