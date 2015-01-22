# MOJ Elements

Common stylesheets and JavaScript for MOJ Digital Serivces which are not already available in [GOV.UK Elements](https://github.com/alphagov/govuk_elements).

## Requirements

* jQuery (for JavaScript)
* [GOV.UK frontend toolkit](https://github.com/alphagov/govuk_frontend_toolkit) (for most Sass modules)
* [GOV.UK template](https://github.com/alphagov/govuk_template)

## Suggested use

A possible way to use these files is to include into your project using [Bower](http://bower.io). Use either source files `src/` or compiled files `dist/`.

    bower install moj_elements --save

Then include the module you require into your manifest or build process.

> Note: JavaScript modules should also include `moj.js` before the module.

## Running tests

Tests for this project use Jasmine for the JavaScript.

The requirements are Node.js and PhantomJS:

```bash
npm install
npm test
```
