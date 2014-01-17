(function(w) {
    w.ga = function(_) {
        console.log("ga(" + Array.prototype.slice.call(arguments).join(", ") + ");");
    };
})(window);
