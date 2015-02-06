/*jslint indent: 4, maxstatements: 27, unused: false */
/*global d3 */
//= require d3.chart.bubble-matrix

'use strict';

var  margin = {top: 10, right: 100, bottom: 100, left: 100};


function percentile(array, n) {
    array.sort(function(a, b) {
        return a - b;
    });
    return array[parseInt(0.01 * n * array.length)];
}

function formatSeconds(s) {
    var output = [],
        d, h, m;

    if (s === 0) {
        return '';
    }
    
    d = s / (24 * 3600);
    s -= parseInt(d) * 24 * 3600;
    if (d > 1) {
        output = output.concat([d.toPrecision(2), 'days']);
    } else {
        h = parseInt(s / 3600);
        s -= h * 3600;
        if (h > 1) {
            output = output.concat([h, 'hrs']);
        } else {
            m = parseInt(s / 60);
            s -= m * 60;
            if (m > 1) {
                output = output.concat([m, 'mins']);
            } else {
                output = output.concat([s, 'secs']);
            }
        }
    }
    return output.join(' ');
}

function formatDate(date) {
    var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return [date.getDate(), months[date.getMonth()]].join(' ');
}
function displayHistogram(where, dataSource, displayLines) {
    var width, height, x, y, n, data, maxY, svg, bars, xAxis, medianValue, percentileValue;

    width = 960 - margin.left - margin.right;
    height = 500 - margin.top - margin.bottom;

    n = dataSource.length;

    x = d3.scale.linear().domain([0, d3.max(dataSource)]).range([0, width]);
    data = d3.layout.histogram().bins(40)(dataSource);
    maxY = d3.max(data, function(d) { return d.y; });
    y = d3.scale.linear().domain([0, maxY]).range([height, 0]);
    svg = d3.select(where).append('svg')
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    bars = svg.selectAll('.bar').data(data).enter().append('g').attr('class', 'bar').attr('transform', function(d) {
        return 'translate(' + x(d.x) + ',' + y(d.y) + ')';
    });
    bars.append('rect').attr('x', 1).attr('width', x(data[0].dx)).attr('height', function(d) { return height - y(d.y); });
    bars.append('text')
        .attr('x', x(data[0].dx / 2))
        .attr('y', -3)
        .attr('font-size', 11)
        .attr('text-anchor', 'middle')
        .text(function(d) { var v = d.y; if (v > 0) { return v; } });
    xAxis = d3.svg.axis().scale(x).orient('bottom').tickFormat(formatSeconds);
    svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + height + ')')
        .call(xAxis);

    if (n === 0) {
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'no-data-label')
            .attr('transform', 'translate(' + (width - 100) / 2 + ',' + height / 2 + ')')
            .text('No data to display');
        return;
    }

    if (displayLines) {
        medianValue = percentile(dataSource, 50);
        percentileValue = percentile(dataSource, 95);

        svg.append('line')
            .attr('x1', x(3 * 24 * 3600))
            .attr('x2', x(3 * 24 * 3600))
            .attr('y1', y(0))
            .attr('y2', y(maxY))
            .attr('class', 'three-days');
        svg.append('line')
            .attr('x1', x(percentileValue))
            .attr('x2', x(percentileValue))
            .attr('y1', y(0))
            .attr('y2', y(maxY))
            .attr('class', 'percentile');
        svg.append('line')
            .attr('x1', x(medianValue))
            .attr('x2', x(medianValue))
            .attr('y1', y(0))
            .attr('y2', y(maxY))
            .attr('class', 'median');
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'three-days-label')
            .attr('transform', 'translate(' + (x(3 * 24 * 3600) + 4) + ',' + y(maxY) + '),rotate(90)')
            .text('three days');
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'percentile-label')
            .attr('transform', 'translate(' + (x(percentileValue) + 4) + ',' + y(maxY) + '),rotate(90)')
            .text('95-th percentile');
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'median-label')
            .attr('transform', 'translate(' + (x(medianValue) + 4) + ',' + y(maxY) + '),rotate(90)')
            .text('median');
    }
}

function displayWeeklyBreakdown(where, rawDataSource) {
    var weekdays, processedData, maxZ, chart, i, z;

    weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    processedData = { columns: [], rows: [] };

    for (i = 0; i < 24; i++) { processedData.columns.push(i); }

    maxZ = 0;
    rawDataSource.forEach(function(row) {
        var max = d3.max(row);
        if (max > maxZ) { maxZ = max; }
    });
    
    z = d3.scale.linear().domain([0, maxZ]).range([0, 1]);

    rawDataSource.forEach(function(row, i) {
        processedData.rows.push({name: weekdays[i], values: row.map(function(f) { return [z(f)]; })});
    });

    chart = d3.select(where).append('svg')
        .chart('BubbleMatrix')
        .width(960)
        .height(300);
    
    chart.draw(processedData);
}

function thisYear() {
    return parseInt(d3.select('#year').html());
}

function displayPerformanceLineChart(where, performanceData, volumeData) {
    var xRange = [new Date(thisYear() - 1, 11, 29), new Date(thisYear() + 1, 0, 1)];
    var y1Range = [0, d3.max(performanceData, function(d) { return parseInt(d.y); })];
    var y2Range = [0, d3.max(volumeData, function(d) { return parseInt(d.y); })];

    var width = 960 - margin.left - margin.right;
    var height = 500 - margin.top - margin.bottom;

    var x = d3.time.scale().domain(xRange).range([0, width]);
    var y1 = d3.scale.linear().domain(y1Range).range([height, 0]);
    var y2 = d3.scale.linear().domain(y2Range).range([height, 0]);

    var xAxis = d3.svg.axis().scale(x).orient('bottom').tickFormat(formatDate);
    var y1Axis = d3.svg.axis().scale(y1).orient('left').tickFormat(formatSeconds);
    var y2Axis = d3.svg.axis().scale(y2).orient('right');

    var svg = d3.select(where)
        .append('svg')
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .append('g');

    svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(' + margin.left + ',' + (height + margin.top) + ')')
        .call(xAxis).selectAll('text')
        .style('text-anchor', 'end')
        .attr('dx', '-.8em')
        .attr('dy', '.15em')
        .attr('transform', function(d) {
            return 'rotate(-45)' 
        });

    svg.append('g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
        .call(y1Axis);

    svg.append('g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(' + (margin.left + width) + ',' + margin.top + ')')
        .call(y2Axis);

    svg.selectAll('bar')
        .data(volumeData)
        .enter().append('rect')
        .style('fill', 'pink')
        .attr('x', function(d) { return x(new Date(d.x)); })
        .attr('y', function(d) { return y2(parseInt(d.y)); })
        .attr('width', 20)
        .attr('height', function(d) { return height - y2(d.y); })
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    var line = d3.svg.line()
        .x(function(d) { return x(new Date(d.x)) })
        .y(function(d) { return y1(parseInt(d.y)) })
    svg.append('path')
        .datum(performanceData)
        .attr('class', 'line')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
        .attr('d', line);
}
