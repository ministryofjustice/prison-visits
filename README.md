# Prison Visit Booking email

Also known as "PVBE", is the Alpha system for the Prison Visit Booking exemplar. 

It is a Ruby on Rails cookie based (no database) service which enables a user to pick 3 posible visiting times and submit the required details of a visit to the relevant prison. 

The request is sent via secure email and prison staff will then manually enter the visit request into NOMIS and respond to the user.

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

For browser tests you will need PhantonJS and CasperJS installed.

    brew update && brew install phantomjs
    brew install casperjs --devel

To run the tests:

    make

If tests fail, a screenshot of the failure can be saved to `/tests/failure.png` by running:

    make test-i