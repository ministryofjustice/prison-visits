describe("CheckboxSummary", function() {
  var fixture;

  beforeEach(function() {
    fixture = $('<div class="CheckboxSummary"></div>');
  });

  it("booleans are treated correctly (example)", function() {
    var check = new moj.Modules._CheckboxSummary(fixture);
    expect(true).toBe(true);
  });


// Settings should return defaults when no options are specified
// Settings should be overridden by options when specified
// Elements should be cached
// Render must is triggered from outside of the module moj.Events
// Summaries are limited to currently checked boxes
// Listed characters can be replaced from the checkbox values
// Summary text is taken from checkbox values
// Summaries are separated by commas by default

});
