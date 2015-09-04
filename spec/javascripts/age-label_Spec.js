describe('AgeLabel', function() {
  var $fixture, subject;

  beforeEach(function() {
    $fixture = $(
      '<div class="AgeLabel" data-threshold="10">'
        + '<div class="AgeLabel-date">'
          + '<input class="year" value="">'
          + '<input class="month" value="5">'
          + '<input class="day" value="20">'
        + '</div>'
        + '<div class="AgeLabel-label">Hello</div>'
      + '</div>'
    );
    $('body').append($fixture);
    subject = new moj.Modules._AgeLabel($fixture);
  });

  afterEach(function() {
    $('body').find('.AgeLabel').remove();
    subject = null;
  })

  it('is an instantiable object', function() {
    expect(typeof subject).toBe('object');
  });

  it('will return the difference between two dates in years', function() {
    expect(subject.getYearsBetween(new Date(2000,5,19), new Date(2014,5,20))).toBe(14);
  });

  it('does not show the label until the date is valid', function() {
    spyOn(moj.Modules._AgeLabel.prototype, 'getDate');
    subject = new moj.Modules._AgeLabel($fixture);
    expect(moj.Modules._AgeLabel.prototype.getDate).toHaveBeenCalled();
    expect($('.AgeLabel-label')).not.toHaveText('Adult');
  });

  describe('when a valid date is entered', function() {

    it('adds the class "over" when the date is above the threshold', function() {
      $fixture.find('input.year').val('1990').change();
      expect($fixture.find('.AgeLabel-label')).toHaveClass('over');
    });

    it('adds the class "under" when the date is below the threshold', function() {
      $fixture.find('input.year').val((new Date()).getFullYear() - 1).change();
      expect($fixture.find('.AgeLabel-label')).toHaveClass('under');
    });

  });

  describe('defaults', function() {

    it('sets the threshold at 18 years', function() {
      var seventeen_years_ago = (new Date()).getFullYear() - 17,
        eighteen_years_ago = (new Date()).getFullYear() - 18;

      $fixture.find('input.year').val(seventeen_years_ago).change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('Child');

      $fixture.find('input.year').val(eighteen_years_ago);
      $fixture.find('input.month').val(1);
      $fixture.find('input.day').val(1).change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('Adult');
    });

    it('shows "Adult" label when over year threshold', function() {
      $fixture.find('input.year').val('1990').change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('Adult');
    });

    it('shows "Child" label when over year threshold', function() {
      $fixture.find('input.year').val((new Date()).getFullYear() - 1).change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('Child');
    });

  });

  describe('options', function() {

    it('should override defaults when options are specified', function() {
      var options = {threshold: '30', labelUnder: 'Old', labelOver: 'Young'},
          subject = new moj.Modules._AgeLabel($fixture, options);
      expect(JSON.stringify(subject.settings)).toBe(JSON.stringify(options));
    });

    it('allows a custom threshold', function() {
      subject = new moj.Modules._AgeLabel($fixture, {threshold: '10'});
      $fixture.find('input.year').val((new Date()).getFullYear() - 11).change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('Adult');
    });

    it('allows custom labels', function() {
      subject = new moj.Modules._AgeLabel($fixture, {labelOver: 'old', labelUnder: 'young'});
      $fixture.find('input.year').val((new Date()).getFullYear() - 11).change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('young');
      $fixture.find('input.year').val(1990).change();
      expect($fixture.find('.AgeLabel-label')).toHaveText('old');
    });

  });

});
