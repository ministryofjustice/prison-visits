describe('TimeoutPrompt', function() {
  var $fixture, subject, minutes;

  minutes = function(num) {
    return num * 1000 * 60;
  };

  beforeEach(function() {
    $fixture = $('<div class="TimeoutPrompt"><script type="text/html" class="TimeoutPrompt-template"><div class="TimeoutPrompt-alert"><p>Would you like to continue?</p><button class="TimeoutPrompt-extend">Yes</button></div></script></div>');
    $('body').append($fixture);

    jasmine.clock().install();
  });

  afterEach(function() {
    jasmine.clock().uninstall();
    $('.TimeoutPrompt').remove();
  });

  it('starts the prompt timer automatically', function() {
    spyOn(moj.Modules._TimeoutPrompt.prototype, 'startTimeout');
    subject = new moj.Modules._TimeoutPrompt($fixture);
    expect(moj.Modules._TimeoutPrompt.prototype.startTimeout).toHaveBeenCalled();
  });

  it('will redirect if the session is not extended', function() {
    spyOn(moj.Modules._TimeoutPrompt.prototype, 'redirect');
    subject = new moj.Modules._TimeoutPrompt($fixture);
    jasmine.clock().tick(minutes(20));
    expect(moj.Modules._TimeoutPrompt.prototype.redirect).toHaveBeenCalled();
  });

  it('is not initially visible', function() {
    expect($('.TimeoutPrompt-alert')).not.toExist();
  });

  describe('alert', function() {

    it('should be triggered after the timeout', function() {
      spyOn(moj.Modules._TimeoutPrompt.prototype, 'showAlert');
      subject = new moj.Modules._TimeoutPrompt($fixture);
      expect(moj.Modules._TimeoutPrompt.prototype.showAlert).not.toHaveBeenCalled();
      jasmine.clock().tick(minutes(17));
      expect(moj.Modules._TimeoutPrompt.prototype.showAlert).toHaveBeenCalled();
    });

    it('uses the a script element for a template', function() {
      expect($fixture.find('.TimeoutPrompt-template')).toExist();
    });

    it('shows the warning message after the respond timeout', function() {
      subject = new moj.Modules._TimeoutPrompt($fixture);
      expect($('.TimeoutPrompt-alert')).not.toBeVisible();
      jasmine.clock().tick(minutes(18));
      expect($('.TimeoutPrompt-alert')).toBeVisible();
      expect($('.TimeoutPrompt')).toContainText('Would you like to continue?');
    });

    it('can be dismissed with a button', function() {
      subject = new moj.Modules._TimeoutPrompt($fixture);
      jasmine.clock().tick(minutes(18));
      expect($('.TimeoutPrompt-extend')).toExist();
      $('.TimeoutPrompt-extend').click();
      expect($('.TimeoutPrompt-alert')).not.toExist();
    });

  });

  describe('options', function() {

    it('will redirect to exit-path', function() {
      spyOn(moj.Modules._TimeoutPrompt.prototype, 'redirect');
      subject = new moj.Modules._TimeoutPrompt($fixture, {exitPath: '/my/exit/path'});
      jasmine.clock().tick(minutes(20));
      expect(moj.Modules._TimeoutPrompt.prototype.redirect).toHaveBeenCalledWith('/my/exit/path');
    });

    it('should override timeout time in minutes', function() {
      spyOn(moj.Modules._TimeoutPrompt.prototype, 'showAlert');
      subject = new moj.Modules._TimeoutPrompt($fixture, {timeoutMinutes: 2});
      jasmine.clock().tick(minutes(2));
      expect(moj.Modules._TimeoutPrompt.prototype.showAlert).toHaveBeenCalled();
    });

    it('should override respond time in minutes', function() {
      spyOn(moj.Modules._TimeoutPrompt.prototype, 'redirect');
      subject = new moj.Modules._TimeoutPrompt($fixture, {timeoutMinutes: 2, respondMinutes: 1});
      jasmine.clock().tick(minutes(3));
      expect(moj.Modules._TimeoutPrompt.prototype.redirect).toHaveBeenCalled();
    });

  });

});
