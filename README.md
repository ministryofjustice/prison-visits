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

## Dependencies

### Modernizr

Used to detect touch enabled devices and whether the device has a native date input. To keep download small, a custom build of Modernizr with only these requirements is in use.

## Automated tests

This app uses [RSpec](http://rspec.info/) for Rails (server-side) tests and [CasperJS](casperjs.org) for (client-side) tests.

### Server-side

    rake

### Client-side

## Locally (using firefox)

    rake spec:features

## Remotely

You'll need to set the environment variables to tell the tests scripts that you want them to be run remotely.

    export BS_USERNAME browserstack-username
    export BS_PASSWORD browserstack-password
    rake spec:features

## In parallel

    rake parallel:spec


