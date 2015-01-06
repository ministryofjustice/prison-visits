describe('CheckboxSummary', function() {
  var $fixture, subject;

  beforeEach(function() {
    $fixture = $('<div class="CheckboxSummary"><input type="checkbox" value="Orange" id="Orange" /><input type="checkbox" value="Green" id="Green" /><span class="CheckboxSummary-summary"></span></div>'),
    subject = new moj.Modules._CheckboxSummary($fixture);
  });

  it('is an instantiable object', function() {
    expect(typeof subject).toBe('object');
  });

  describe('settings', function() {
    it('should return defaults when no options are specified', function() {
      expect(JSON.stringify(subject.settings)).toBe(JSON.stringify(subject.defaults));
    });

    it('should override defaults when options are specified', function() {
      var options = {glue: '-', strip: ':', sub: '_', original: 'original'},
          subject = new moj.Modules._CheckboxSummary($fixture, options);
      expect(JSON.stringify(subject.settings)).toBe(JSON.stringify(options));
    });

    it('should separate summary items with commas by default', function() {
      $fixture.find('#Orange, #Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange, Green');
    });

    it('should remove text from summaries when checked selections are un-checked', function() {
      $fixture.find('#Orange, #Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange, Green');
      $fixture.find('#Orange').prop('checked', false).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Green');
    });

    it('should separate items with a string when specified', function() {
      var subject = new moj.Modules._CheckboxSummary($fixture, {glue: ' - '});
      $fixture.find('#Orange, #Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange - Green');
    });

    it('should replace a list of characters from summary text', function() {
      var subject = new moj.Modules._CheckboxSummary($fixture, {strip: 'e', sub: 'o'});
      $fixture.find('#Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Groon');
    });

    it('should display placeholder text when no items are checked', function() {
      $fixture.find('#Orange').prop('checked', true).change();
      $fixture.find('#Orange').prop('checked', false).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('[summary]');
    });

    it('should display custom placeholder text when specified', function() {
      $fixture = $('<div class="CheckboxSummary"><input type="checkbox" value="Blue" id="Blue" /><span class="CheckboxSummary-summary">something else</span></div>');
      $fixture.find('#Blue').prop('checked', true).change();
      $fixture.find('#Blue').prop('checked', false).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('something else');
    });
  });

  it('caches elements for reuse', function() {
    expect(subject.$checkboxes.length).toBe(2);
    expect(subject.$summaries.length).toBe(1);
  });

  it('is rendered by moj.Events module', function() {
    $fixture = $('<div class="CheckboxSummary"><input type="checkbox" value="Orange" id="Orange" /><input type="checkbox" value="Green" id="Green" checked="checked" /><span class="CheckboxSummary-summary"></span></div>'),
    subject = new moj.Modules._CheckboxSummary($fixture);
    moj.Events.trigger('render');
    expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Green');
  });

  it('creates a summary from currently checked boxes', function() {
    $fixture.find('#Orange').prop('checked', true).change();
    expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange');
    expect(subject.getChecked(subject.$checkboxes).length).toBe(1);
  });

  it('uses checkbox values as summary text', function() {
    $fixture.find('#Orange').prop('checked', true).change();
    expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange');
  });

});
