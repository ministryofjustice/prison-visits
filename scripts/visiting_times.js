/*jshint strict:false*/
/*global CasperError, console, phantom, require*/

var casper = require("casper").create();
var utils = require("utils");
var url = "http://www.insidetime.co.uk/info-visitorsinfo.asp?nameofprison=";
var times = [];
var prison_data = {};

var prison_details = {
"HMP BEDFORD": {"address":"St. Loyes Street,MK40 1HG","email":"SocialVisits.Bedford@hmps.gsi.gov.uk","tel":"01234 373196"},
"HMP BLANTYRE HOUSE": {"address":"Goudhurst,TN17 2NH","email":"SocialVisits.BlantyreHouse@hmps.gsi.gov.uk","tel":""},
"HMP BRIXTON": {"address":"Jebb Avenue,SW2 5XF","email":"socialvisitsbrixton@hmps.gsi.gov.uk","tel":"0208 678 1433"}};

var prison_details2 = {
"HMP BULLINGDON": {"address":"Bicester,OX25 1PZ ","email":"socialvisits.bullingdon@hmps.gsi.gov.uk","tel":"01869 353176"},
"HMP-YOI CHELMSFORD": {"address":"200 Springfield Road,CM2 6LQ ","email":"SocialVisits.Chelmsford@hmps.gsi.gov.uk","tel":"01245 552265"},
"HMP DOWNVIEW": {"address":"Sutton Lane,SM2 5PD","email":"socialvisits.downview@hmps.gsi.gov.uk","tel":"0208 196 6359"},
"HMP-YOI EAST SUTTON PARK": {"address":"Sutton Valence,ME17 3DF ","email":"Socialvisits.Eastsuttonpark@hmps.gsi.gov.uk","tel":""},
"HMP SHEPPEY CLUSTER - ELMLEY": {"address":"Church Road,ME12 4DZ ","email":"SocialVisits.Elmley@hmps.gsi.gov.uk","tel":"0300 060 6605"},
"HMP EVERTHORPE": {"address":"1a Beck Road,HU15 1RB","email":"SocialVisits.Everthorpe@hmps.gsi.gov.uk","tel":"01430 426505"},
"HMYOI FELTHAM": {"address":"Bedfont Road,TW13 4ND ","email":"socialvisits.feltham@hmps.gsi.gov.uk","tel":"0208 844 5400"},
"HMYOI GLEN PARVA": {"address":"Tigers Road,LE8 4TN ","email":"socialvisits.glenparva@hmps.gsi.gov.uk","tel":"0116 228 4366"},
"HMP GRENDON": {"address":"Grendon Underwood,HP18 0TL","email":"socialvisits.Grendon@hmps.gsi.gov.uk","tel":""},
"HMP GUYS MARSH": {"address":"SHAFTESBURY,SP7 0AH ","email":"SocialVisitsGuysMarsh@hmps.gsi.gov.uk","tel":"01747 856586"},
"HMP-YOI HATFIELD (MOORLAND OPEN)": {"address":"Thorne Road,DN7 6El","email":"SocialVisits.Hatfield@hmps.gsi.gov.uk","tel":"01405 746611"},
"HMP HAVERIGG": {"address":"MILLOM,LA18 4NA ","email":"socialvisits.haverigg@hmps.gsi.gov.uk","tel":"01229713016"},
"HMP HIGH DOWN": {"address":"Sutton Lane,SM2 5PJ ","email":"socialvisits.highdown@hmps.gsi.gov.uk","tel":"0300 060 6503"},
"HMP HIGHPOINT": {"address":"Stradishall,CB8 9YG ","email":"SocialVisits.Highpoint @hmps.gsi.gov.uk","tel":"0207 147 6570"},
"HMYOI HINDLEY": {"address":"Gibson Street,WN2 5TH ","email":"socialvisits.hindley@hmps.gsi.gov.uk","tel":"01440 743134"},
"HMP HOLLESLEY BAY": {"address":"WOODBRIDGE,IP12 3JW ","email":"SocialVisits.HollesleyBay@hmps.gsi.gov.uk","tel":""},
"HMP-YOI HOLLOWAY": {"address":"Parkhurst Road,N7 0NU ","email":"socialvisits.holloway@hmps.gsi.gov.uk","tel":""},
"HMP HOLME HOUSE": {"address":"Holme House Road,S18 2QU","email":"SocialVisits@hmpholme house.gsi.gov.uk","tel":"03000 606602"},
"HMP HULL": {"address":"Hedon Road,HU9 5LS ","email":"SocialVisits.Hull@hmps.gsi.gov.uk","tel":"01482 282016"},
"HMP HUNTERCOMBE": {"address":"Huntercombe Place,RG9 5SB ","email":"socialvisits.huntercombe@hmps.gsi.gov.uk","tel":"01302 524980"},
"HMP ISLE OF WIGHT - PARKHURST": {"address":"Clissold Road ,PO30 5RS ","email":"visitshmpiow@hmps.gsi.gov.uk","tel":"01983 634218"},
"HMP KENNET": {"address":"Parkbourn,L31 1HX ","email":"socialvisits.kennet@hmps.gsi.gov.uk","tel":"0151 213 3179"},
"HMP KIRKHAM": {"address":"Freckleton Road, Kirkham,PR4 2RN","email":"socialvisits.kirkham@hmps.gsi.gov.uk","tel":""},
"HMYOI LANCASTER FARMS": {"address":"Stone Row Head,LA1 3QZ","email":"socialvisits.lancasterfarms@hmps.gsi.gov.uk","tel":"01524 563636"},
"HMP LEEDS": {"address":"Gloucester Terrace,LS12 2TJ ","email":"SocialVisits.Leeds@hmps.gsi.gov.uk","tel":"0113 203 2995"},
"HMP LEICESTER": {"address":"116 Welford Road,LE2 7AJ","email":"No Active Social Visits FMB","tel":"0116 228 3128"},
"HMP LINCOLN": {"address":"Greetwell Road,LN2 4BD ","email":"socialvisits.Lincoln@hmps.gsi.gov.uk","tel":"01522 663172"},
"HMP LINDHOLME": {"address":"Bawtry Road,DN7 6EE ","email":"SocialVisits.Lindholme@hmps.gsi.gov.uk","tel":"01302 524980"},
"HMP-YOI LITTLEHEY": {"address":"Perry,PE28 0SR","email":"socialvisits.littlehey@hmps.gsi.gov.uk","tel":"01480 335650"},
"HMP MAIDSTONE": {"address":"36 County Road,ME14 1UZ ","email":"Socialvisits.maidstone@hmps.gsi.gov.uk","tel":"016220775619"},
"HMP-YOI NEW HALL": {"address":"Dial Wood,WF4 4XX","email":"SocialVisits.NewHall@hmps.gsi.gov.uk","tel":"01924 803219"},
"HMP NORTH SEA CAMP": {"address":"Freiston,PE22 0QX","email":"SocialVisits.NorthSeaCamp@hmps.gsi.gov.uk","tel":"01205 769 368"},
"HMP-YOI NORWICH": {"address":"Knox Road,NR1 4LU ","email":"socialvisits.norwich@hmps.gsi.gov.uk","tel":"01603 708795"},
"HMP NOTTINGHAM": {"address":"Perry Road,NG5 3AG ","email":"SocialVisits.Nottingham@hmps.gsi.gov.uk","tel":"0115 962 8980"},
"HMYOI PORTLAND": {"address":"104 The Grove,DT5 1DL","email":"SocialVisits.Portland@hmps.gsi.gov.uk","tel":"01305 715775"},
"HMP PRESCOED": {"address":"Coed-y-Paen,NP4 0TB","email":"Not required","tel":""},
"HMP PRESTON": {"address":"2 Ribbleton Lane,PR1 5AB ","email":"","tel":"01772 444666"},
"HMP RANBY": {"address":"RETFORD,DN22 8EU","email":"visitsbookingranby@hmps.gsi.gov.uk","tel":"01777 862107"},
"HMP SEND": {"address":"Ripley Road,GU23 7LJ ","email":"SocialVisits.Send@hmps.gsi.gov.uk","tel":"01483 471033"},
"HMP SPRING HILL": {"address":"Grendon Underwood,HP18 0TL ","email":"","tel":""},
"HMP SHEPPEY CLUSTER - STANDFORD HILL": {"address":"Church Road,ME12 4AA ","email":"SocialVisits.StandfordHill@hmps.gsi.gov.uk","tel":"0300 060 6603"},
"HMP STYAL": {"address":"WILMSLOW,SK9 4HR ","email":"socialvisits.styal@hmps.gsi.gov.uk","tel":"01625553195"},
"HMP SUDBURY": {"address":"Ashbourne,DE6 5HW ","email":"","tel":""},
"HMP SHEPPEY CLUSTER - SWALESIDE": {"address":"Brabazon Road,ME12 4AX","email":"SocialVisits.Swaleside@hmps.gsi.gov.uk","tel":"0300 060 6604"},
"HMP SWANSEA": {"address":"200 Oystermouth Road,SA1 3SR","email":"socvisswansea@hmps.gsi.gov.uk","tel":"01792 48 5322"},
"HMP USK": {"address":"47 Maryport Street,NP15 1XP","email":"Social Visits, Usk","tel":"01291 671730"},
"HMP WANDSWORTH": {"address":"PO Box 757,SW18 3HS","email":"socialvisits.wandsworth@hmps.gsi.gov.uk","tel":"01924 612274"},
"HMP-YOI WARREN HILL": {"address":"Hollesley,IP12 3JW ","email":"SocialVisits.WarrenHill@hmps.gsi.gov.uk","tel":"020 8588 4002"},
"HMYOI WETHERBY": {"address":"York Road,LS22 5ED ","email":"SocialVisits.Wetherby@hmps.gsi.gov.uk","tel":"01937 544207"},
"HMP WINCHESTER": {"address":"Romsey Road,SO22 5DF","email":"Socialvisits.winchester@hmps.gsi.gov.uk","tel":"0845 223 5514"},
"HMP WOLDS": {"address":"Everthorpe,HU15 2JZ ","email":"?","tel":"01430 428584"},
"HMP WORMWOOD SCRUBS": {"address":"Du Cane Road,W12 0AE","email":"socialvisits.WormwoodScrubs@hmps.gsi.gov.uk","tel":"020 8588 3564"},
"HMP WYMOTT": {"address":"Ulnes Walton Lane,PR26 8LW","email":"socialvisits.wymott@hmps.gsi.gov.uk","tel":"01772 442234"}
};

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
// prisons = ['HMP-YOI CHELMSFORD'];

casper.start("http://www.google.com", function () {

  // for (var prison in prison_details) {
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

      var time_slots = this.evaluate(function () {

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
          s = s.replace(/\u2013|\u2014/g, "-");
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

      });
      // end evaluate

      obj[formatForPVB(prison)] = time_slots;

      times.push(obj);
      // prison_details[prison].enabled = false;
      // prison_details[prison].slots = time_slots;
    });
  });
});

casper.run(function() {
  utils.dump(times);
  var fs = require('fs');
  fs.write('prison_data.json', JSON.stringify(times), 'w');
  this.exit();
});
