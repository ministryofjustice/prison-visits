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

    it('should be overridden by options when specified', function() {
      var options = {glue: '-', strip: ':', sub: '_', original: 'original'},
          subject = new moj.Modules._CheckboxSummary($fixture, options);
      expect(JSON.stringify(subject.settings)).toBe(JSON.stringify(options));
    });

    it('summary items are separated by commas by default', function() {
      $fixture.find('#Orange, #Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange, Green');
    });

    it('correctly summarises checked selections between every change', function() {
      $fixture.find('#Orange, #Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange, Green');
      $fixture.find('#Orange').prop('checked', false).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Green');
    });

    it('summary items are separated by optional string', function() {
      var subject = new moj.Modules._CheckboxSummary($fixture, {glue: ' - '});
      $fixture.find('#Orange, #Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange - Green');
    });

    it('optional list of characters can be removed from summary text', function() {
      var subject = new moj.Modules._CheckboxSummary($fixture, {strip: 'e', sub: 'o'});
      $fixture.find('#Green').prop('checked', true).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Groon');
    });

    it('original placeholder text is used when summary is blank', function() {
      $fixture.find('#Orange').prop('checked', true).change();
      $fixture.find('#Orange').prop('checked', false).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('[summary]');
    });

    it('optional placeholder text is used when specified', function() {
      $fixture = $('<div class="CheckboxSummary"><input type="checkbox" value="Blue" id="Blue" /><span class="CheckboxSummary-summary">something else</span></div>');
      $fixture.find('#Blue').prop('checked', true).change();
      $fixture.find('#Blue').prop('checked', false).change();
      expect($fixture.find('.CheckboxSummary-summary').text()).toBe('something else');
    });
  });

  it('elements are cached', function() {
    expect(subject.$checkboxes.length).toBe(2);
  });

  it('render is triggered from moj.Events module', function() {
    $fixture = $('<div class="CheckboxSummary"><input type="checkbox" value="Orange" id="Orange" /><input type="checkbox" value="Green" id="Green" checked="checked" /><span class="CheckboxSummary-summary"></span></div>'),
    subject = new moj.Modules._CheckboxSummary($fixture);
    moj.Events.trigger('render');
    expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Green');
  });

  it('summaries are limited to currently checked boxes', function() {
    $fixture.find('#Orange').prop('checked', true).change();
    expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange');
    expect(subject.getChecked(subject.$checkboxes).length).toBe(1);
  });

  it('summary text is taken from checkbox values', function() {
    $fixture.find('#Orange').prop('checked', true).change();
    expect($fixture.find('.CheckboxSummary-summary').text()).toBe('Orange');
  });

});
