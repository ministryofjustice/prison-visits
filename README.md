# Prison Visit Booking email

[![Build Status](https://travis-ci.org/ministryofjustice/prison-visits.png?branch=master)](https://travis-ci.org/ministryofjustice/prison-visits)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/prison-visits.png)](https://codeclimate.com/github/ministryofjustice/prison-visits)
[![Code Coverage](https://codeclimate.com/github/ministryofjustice/prison-visits/coverage.png)](https://codeclimate.com/github/ministryofjustice/prison-visits)

Also known as "PVBE", is the Alpha system for the Prison Visit Booking exemplar. 

It is a Ruby on Rails cookie based (no database) service which enables a user to pick 3 posible visiting times and submit the required details of a visit to the relevant prison. 

The request is sent via secure email and prison staff will then manually enter the visit request into NOMIS and respond to the user.

## Editing prison data

Prison details are store in a single Yaml file which can be edited directly on this website by anyone with access to this repository. [Yaml files](http://en.wikipedia.org/wiki/YAML) use a two-space indentation syntax, so be careful.

The [staging data](config/prison_data_staging.yml) must contain all the same parameters as [production](config/prison_data_production.yml), but not the same values.

### Prison visibility

All known prisons should exist in the data files. If a prison is not in scope of the service, it should be disabled and can be given a specific reason.

To enable visit requests to a prison, set `enabled` to `true`.

    Rochester:
      enabled: true // this prison accepts visit requests
    
    Stafford:
      enabled: false // this prison does not accept online visit request through this service

When a disabled prison is chosen on the prisoner details page, the user is shown this message:

> HMP [PRISON_NAME] is unable to process online visit requests. Instead you can contact the prison directly to book a visit.
	
This message can be changed to one of two other reasons using the `reason` parameter.

    reason: 'it_issues'
    // HMP [PRISON_NAME] is unable to process online visit requests right now. You can contact the prison directly to book a visit instead.
    
	reason: 'coming_soon'
	// HMP [PRISON_NAME] isn’t able to process online visit requests yet. You can contact the prison directly to book a visit instead.

### Weekly visiting slots

Slots are defined per prison via a weekly schedule. Only days listed here with a list of slots will appear on the slot picker. 

Use 3 letter strings for days of the week. Times are entered in 24 hours format.

    slots:
      wed:
      - 1350-1450 // creates a 1 hour slot every Wednesday from 1:50pm
      sat:
      - 0900-1100 // creates a 2 hour slot every Saturday from 9am
      - 1330-1530 // creates a 2 hour slot every Saturday from 1:30pm

### Slot anomalies

Use this to make exceptions to the weekly schedule.

When a day is found in `slot_anomalies` the whole day is replaced with this data. Therefore if the weekday usually contains multiple slots and only a single slot is to be edited, the rest of the slots need to be re-entered.

	slot_anomalies:
	  2015-01-10:
      - 0930-1130 // replaces Saturday 10 January 2015 with only one slot at 9:30am

**Note** Slot anomalies must be listed in chronological order.

### Non-bookable days

Use this to remove specified dates from the weekly schedule. Eg staff training days, Christmas day.

This overrides both `slots` and `slot_anomalies`.

    unbookable:
    - 2015-12-25 // removes any slots from 25 December 2015

**Note** Unbookable dates must be listed in chronological order.

### Response times

Set the amount of full working days which booking staff have to respond to each request. The default is 3 days.

Eg One Monday, requests can be made for Friday. Set to `2` and it will be possible to make requests for Thursday.

	lead_days: 2 // two full working days after current day

### Working days

Use this when a prison has booking staff who can respond to requests over weekends. This will allow visits to be requested 3 days ahead (or custom `lead_day`) regardless of whether they are 'week days'.

	works_weekends: true

### Prison finder links

When the services links to [Prison Finder](https://www.justice.gov.uk/contacts/prison-finder) it turns the prison name into part of the URL. Eg 'Drake Hall' becomes [drake-hall](https://www.justice.gov.uk/contacts/prison-finder/drake-hall).

When the Prison Finder link doesn't not simply match the prison name in lower case with spaces replaced with hyphens, use this.

	finder_slug: moorland

### Canned responses

The visit request processing form has been updated and can be enabled per prison.

    canned_responses: true

## Set-up

Clone the project into a directory on to your environment using [instructions on GitHub](https://help.github.com/categories/54/articles). 

Open terminal and go to the project directory and install the dependancies by running (assuming you have [Bundler](http://bundler.io/) installed):

    bundle install
    
Run the server by running:

    rails server

Then point your favourite browser to [http://localhost:3000/](http://localhost:3000/).

## Dependencies

### SlotPicker

Used for choose and choose-date-and-time page. 

This is included via a [Bower package](http://bower.io). To update run `bower update`.

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


