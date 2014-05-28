/*jshint strict:false*/
/*global CasperError, console, phantom, require*/

var casper = require("casper").create();
var utils = require("utils");
var venue = casper.cli.get(0);
var url = "http://www.insidetime.co.uk/info-visitorsinfo.asp?nameofprison=";
var times = [];

if (!venue) {
  casper
    .echo("Usage: $ casperjs prison_times.js <prison_name>")
    .exit(1)
  ;
}

url+= venue.toUpperCase();

casper.start(url, function () {
  times = this.evaluate(function () {

    var nodes, slots = {};

    // filter-out text nodes
    var onlyElements = function (nodes) {
      var elements = [];
      [].forEach.call(nodes, function (node) {
        if (node.nodeType == 1) {
          return elements.push(node);
        }
      });
      return elements;
    };

    var format = function (s) {
      return s.split("&").map(function (i) {
        return i.replace(/[: ]/g,'');
      });
    };

    // get tbody
    var nodes = onlyElements( document.querySelector('a[name=vtimes]').nextSibling.nextSibling.childNodes );

    // get table rows
    nodes = onlyElements( nodes[0].childNodes );

    // strip-off heading row
    nodes = [].slice.call(nodes, 1);

    [].forEach.call(nodes, function (row) {
      if (row.childNodes.length > 3) {
        slots[row.childNodes[1].textContent.substr(0,3).toLowerCase()] = format( row.childNodes[3].textContent )
      }
    });

    return slots;

  });
});

casper.run(function() {
  utils.dump(times);
  var fs = require('fs');
  fs.write('prison_data.json', JSON.stringify(times), 'w');
  this.exit();
});
