# Prison Visit Booking email

Also known as "PVBE", is the Alpha system for the Prison Visit Booking exemplar. 

It is a Ruby on Rails cookie based (no database) service which enables a user to pick 3 posible visiting times and submit the required details of a visit to the relevant prison. 

The request is sent via secure email and prison staff will then manually enter the visit request into NOMIS and respond to the user.

## Editing prison details

Prison details are store in a single Yaml file which can be edited directly on this website by anyone with access to this repository. [Yaml files](http://en.wikipedia.org/wiki/YAML) use a two-space indentation syntax, so be careful.

[prison_detail.yaml](https://github.com/ministryofjustice/prison-visits2/blob/master/config/prison_data.yml)

By updating this file you can:

* Add/remove a prison
* Edit visiting slots
* Edit un-bookable dates
* Edit booking email address
* Edit booking phone number
* Edit prison address

## Set-up

Clone the project into a directory on to your environment using [instructions on GitHub](https://help.github.com/categories/54/articles). 

Open terminal and go to the project directory and install the dependancies by running (assuming you have [Bundler](http://bundler.io/) installed):

    bundle install
    
Run the server by running:

    rails server

Then point your favourite browser to [http://localhost:3000/](http://localhost:3000/).

## Automated tests

This app uses [RSpec](http://rspec.info/) for Rails (server-side) tests and [CasperJS](casperjs.org) for (client-side) tests.

### Server-side

    rake

### Client-side

**Note:** the server must be running for these tests to run.

For browser tests you will need PhantonJS and CasperJS installed.

    brew update && brew install phantomjs
    brew install casperjs --devel

To run the tests:

    make

To see a screen shot of each completed step run:

    make test-i

If tests fail, a screenshot of the failure is saved to `/tests/failure.png`.

#### GruntJS

For convenience, GruntJS has been added to watch the `app/` and `tests/` folders for changes and automatically run the lint and integration tests. Assuming you have [NodeJS](http://nodejs.org/) installed, run `npm install` and then one of the following commands:

    grunt             # JS lint application code
    grunt tests       # run integration tests
    grunt watch       # monitor all
    grunt watch:app   # monitor /app JS and run lint automatically
    grunt watch:tests # monitor test scripts and run automatically
