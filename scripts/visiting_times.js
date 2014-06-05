/*jshint strict:false*/
/*global CasperError, console, phantom, require*/

var casper = require("casper").create();
var utils = require("utils");
var url = "http://www.insidetime.co.uk/info-visitorsinfo.asp?nameofprison=";
var times = [];

var prisons = [
'HMYOI AYLESBURY',
'HMP BEDFORD',
'HMP BLANTYRE HOUSE',
'HMP BRISTOL',
'HMP BRIXTON', // commas
'HMP BULLINGDON',
'HMP BURE',
'HMP-YOI CHELMSFORD',
'HMP COLDINGLEY', // (enhancedonly)
'HMYOI DEERBOLT',
'HMP DOWNVIEW',
'HMP-YOI EAST SUTTON PARK',
'HMP SHEPPEY CLUSTER - ELMLEY',
'HMP EVERTHORPE',
'HMP-YOI EXETER',
'HMYOI FELTHAM',
'HMP FOSTON HALL',
'HMYOI GLEN PARVA', // (closedvisits1400-1500) flag
'HMP GRENDON',
'HMP GUYS MARSH',
'HMP-YOI HATFIELD (MOORLAND OPEN)',
'HMP HAVERIGG',
'HMP HIGH DOWN', // (enhancedonly)
'HMP HIGHPOINT', // split north/south
'HMYOI HINDLEY', // flag - youth times
'HMP HOLLESLEY BAY',
'HMP HOLME HOUSE', // 000000
'HMP HULL', // joined times
'HMP HUNTERCOMBE',
'HMP ISLE OF WIGHT - PARKHURST',
'HMP KENNET',
'HMP KIRKHAM',
'HMYOI LANCASTER FARMS',
'HMP LEEDS', // commas
'HMP LEICESTER',
'HMP LEWES',
'HMP LINCOLN',
'HMP LINDHOLME',
'HMP-YOI LITTLEHEY', // (YOI)
'HMP MAIDSTONE',
'HMP-YOI MOORLAND CLOSED',
'HMP-YOI NEW HALL',
'HMP NORTH SEA CAMP',
'HMP-YOI NORWICH', // flag - times per wing
'HMP NOTTINGHAM',
'HMYOI PORTLAND',
'HMP PRESCOED',
'HMP PRESTON',
'HMP RANBY',
'HMP SEND',
'HMP SPRING HILL',
'HMP SHEPPEY CLUSTER - STANDFORD HILL',
'HMP STYAL',
'HMP SUDBURY',
'HMP SHEPPEY CLUSTER - SWALESIDE',
'HMP SWANSEA', // commas
'HMP THE MOUNT',
'HMP USK',
'HMP WANDSWORTH', // commas
'HMP-YOI WARREN HILL',
'HMP WEALSTUN',
'HMYOI WETHERBY',
'HMP WINCHESTER',
'HMP WOLDS',
'HMP WORMWOOD SCRUBS', // (18+only)
'HMP WYMOTT'
];

// For testing with specific prisons
prisons = ['HMP HOLME HOUSE'];

casper.start("http://www.google.com", function () {

  prisons.forEach(function (prison) {

    casper.thenOpen(url + prison.replace(/ /g, '_'), function () {

      var obj = {};

      var formatForPVB = function (s) {
        var words;
        s = s.replace(/(HMP|HMYOI|HMP-YOI) /, '');
        words = s.split(' ');
        return words.map(function (word) {
          return word[0] + word.substr(1).toLowerCase();
        }).join(' ');
      };

      var details = {

        "slots": this.evaluate(function () {

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

          var normaliseTimes = function (s) {
            s = s.replace(/and/g,'&');
            s = s.replace(/to/g,'-');
            return s;
          };

          var ignoreWords = function (s) {
            s = s.replace(/\(mains\)/gi,'');
            s = s.replace(/\(vps\)/gi,'');
            s = s.replace(/\(yoi\)/gi,'');
            s = s.replace(/\(enhancedonly\)/gi,'');
            return s;
          };

          var formatString = function (s) {
            s = s.replace(/[ :;\.]/g,'');
            return s;
          };

          var timeArrayFromString = function (t) {
            var startTimes = t.split(','),
                times = [];

            for (var i = 0; i < startTimes.length; i++) {
              times.push([startTimes[i], addHours(startTimes[i], 1)].join('-'));
            }

            return times;
          };

          var addHours = function(start, hours) {
            var time = new Date();

            // set initial time
            time.setHours(start.substr(0, 2));
            time.setMinutes(start.substr(2));

            time.setHours(time.getHours()+hours);

            return [pad(time.getHours()),pad(time.getMinutes())].join('');
          };

          var pad = function (num) {
            return ("00"+num).slice(-2);
          };

          var commaSeparatedTimes = function (times) {
            return times.join('').indexOf('-') > -1;
          };

          var commaSeparatedStartTimes = function (times) {
            return times.join('').indexOf(',') > -1;
          };

          var fixKnownIssues = function (times, prison) {
            switch (prison) {
              case 'HOLME_HOUSE':
                times = times.join(',').replace('190000','1900').split(',');
                break;
              case 'LEEDS':
                times = times.join(',').replace('10130','1030').split(',');
                break;
            }

            return times;
          };

          var prisonName = function () {
            return document.location.href.split('=')[1].replace(/(HMP|HMYOI|HMP-YOI)_/, '');
          };

          var extractTimes = function (s) {
            var times;

            s = formatString(s);

            s = ignoreWords(s);

            s = normaliseTimes(s);

            times = s.split("&");

            if (commaSeparatedTimes(times)) {
              times = times.join(',').split(',');
            }

            if (commaSeparatedStartTimes(times)) {
              times = timeArrayFromString(times.join(','));
            }

            times = fixKnownIssues(times, prisonName());

            return times;
          };

          // get tbody
          nodes = onlyElements( document.querySelector('a[name=vtimes]').nextSibling.nextSibling.childNodes );

          // get table rows
          nodes = onlyElements( nodes[0].childNodes );

          // strip-off heading row
          nodes = [].slice.call(nodes, 1);

          [].forEach.call(nodes, function (row) {
            if (row.childNodes.length > 3) {
              slots[row.childNodes[1].textContent.substr(0,3).toLowerCase()] = extractTimes( row.childNodes[3].textContent );
            }
          });

          return slots;

        })
      };

      obj[formatForPVB(prison)] = details;

      times.push(obj);
    });
  });
});

casper.run(function() {
  utils.dump(times);
  var fs = require('fs');
  fs.write('prison_data.json', JSON.stringify(times), 'w');
  this.exit();
});
