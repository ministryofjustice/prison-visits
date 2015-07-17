# Visit someone in prison

[![Circle CI](https://circleci.com/gh/ministryofjustice/prison-visits.svg?style=svg)](https://circleci.com/gh/ministryofjustice/prison-visits)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/prison-visits.png)](https://codeclimate.com/github/ministryofjustice/prison-visits)
[![Code Coverage](https://codeclimate.com/github/ministryofjustice/prison-visits/coverage.png)](https://codeclimate.com/github/ministryofjustice/prison-visits)

Also known as “Prison visit booking”, is one of the 25 'exemplar' [government digital transformation services](https://www.gov.uk/transformation).

It is a Ruby on Rails cookie based (no database) service which enables a user to pick 3 posible visiting times and submit the required details of a visit to the relevant prison. 

The request is sent via secure email to prison staff who manually process the request before returning to this app to respond to the user.

## Editing prison data

Prison details are store in a single Yaml file which can be edited directly on this website by anyone with access to this repository. [Yaml files](http://en.wikipedia.org/wiki/YAML) use a two-space indentation syntax, so be careful.

**Note** the [staging data](config/prison_data_staging.yml) must contain all the same slots, anomalies and non-bookable dates as [production](config/prison_data_production.yml) in order for it to behave the same for testing.

### Prison visibility

All known prisons should exist in the data files. If a prison is not in scope of the service, it should be disabled and can be given a specific reason.

To enable visit requests to a prison, set `enabled` to `true`.

```yaml
Rochester:
  enabled: true # this prison accepts visit requests

Stafford:
  enabled: false # this prison does not accept online visit request through this service
```

When a disabled prison is chosen on the prisoner details page, the user is shown this message:

> HMP [PRISON_NAME] is unable to process online visit requests. Instead you can contact the prison directly to book a visit.

This message can be changed using the `reason` parameter.

```yaml
reason: 'it_issues'
```

Will change the message to:

> HMP [PRISON_NAME] is unable to process online visit requests right now. You can contact the prison directly to book a visit instead.

```yaml
reason: 'coming_soon'
```

Will change the message to:

> HMP [PRISON_NAME] isn’t able to process online visit requests yet. You can contact the prison directly to book a visit instead.

### Weekly visiting slots

Slots are defined per prison via a weekly schedule. Only days listed here with a list of slots will appear on the slot picker. 

Use 3 letter strings for days of the week. Times are entered in 24 hours format.

```yaml
slots:
  wed:
  - 1350-1450 # creates a 1 hour slot every Wednesday from 1:50pm
  sat:
  - 0900-1100 # creates a 2 hour slot every Saturday from 9am
  - 1330-1530 # creates a 2 hour slot every Saturday from 1:30pm
```

### Slot anomalies

Use this to make exceptions to the weekly schedule.

When a day is found in `slot_anomalies` the whole day is replaced with this data. Therefore if the weekday usually contains multiple slots and only a single slot is to be edited, the rest of the slots need to be re-entered.

```yaml
slot_anomalies:
  2015-01-10:
  - 0930-1130 # replaces Saturday 10 January 2015 with only one slot at 9:30am
```

**Note** slot anomalies must be listed in chronological order.

### Non-bookable days

Use this to remove specified dates from the weekly schedule. Eg staff training days, Christmas day.

This overrides both `slots` and `slot_anomalies`.

```yaml
unbookable:
- 2015-12-25 # removes any slots from 25 December 2015
```

**Note** unbookable dates must be listed in chronological order.

### Response times

Set the amount of full working days which booking staff have to respond to each request. The default is 3 days.

Eg One Monday, requests can be made for Friday. Set to `2` and it will be possible to make requests for Thursday.

```yaml
lead_days: 2 # two full working days after current day
```

### Working days

Use this when a prison has booking staff who can respond to requests over weekends. This will allow visits to be requested 3 days ahead (or custom `lead_day`) regardless of whether they are 'week days'.

```yaml
works_weekends: true
```

### Prison finder links

When the services links to [Prison Finder](https://www.justice.gov.uk/contacts/prison-finder) it turns the prison name into part of the URL. Eg 'Drake Hall' becomes [drake-hall](https://www.justice.gov.uk/contacts/prison-finder/drake-hall).

When the Prison Finder link doesn't not simply match the prison name in lower case with spaces replaced with hyphens, use this.

```yaml
finder_slug: sheppey-cluster-standford-hill
```

### Canned responses

The visit request processing form has been updated and can be enabled per prison.

```yaml
canned_responses: true
```

### Adult age

Visit requests are limited to a maximum of 3 "adults" (18 years old and over, by default). The adult age can be reduced to restrict the amount of visitors over that age.

**Note** visiting areas have 3 seats for visitors and one for the prisoner. Children are expect to sit on the laps of adults.

```yaml
adult_age: 15 # allow only 3 visitors over the age of 15
```

## Renaming a prison

Follow these steps if you need to rename a prison.

1. Rename the prison name `key` in the Yaml file ([see above](#prison-visibility)).

2. Register the old name in the [`legacy_data_fixes` method](https://github.com/ministryofjustice/prison-visits/blob/master/app/controllers/deferred/confirmations_controller.rb#L67), using the old name as the key, and the new name as the value.

3. Write a migration to rename old records ([see this example](https://github.com/ministryofjustice/prison-visits/commit/46a713811ae1875f12e9b85dab397eef2088afa8)).

### Combining prisons

If a two or more prisons are combined, a similar process should be followed. See [commit 7afd6a0](https://github.com/ministryofjustice/prison-visits/commit/7afd6a0ad7ce6084184be68df6ff80040f999c1e) for details.

## Set-up

Clone the project into a directory on to your environment using [instructions on GitHub](https://help.github.com/categories/54/articles).

Open terminal and go to the project directory and install the dependancies by running (assuming you have [Bundler](http://bundler.io/) installed):

    bundle install
   
Run the server by running:

    rails server

Then point your favourite browser to [http://localhost:3000/prisoner](http://localhost:3000/prisoner).

**Note** as services on GOV.UK should not be accessed directly, the root of this app redirects to www.gov.uk/prison-visits.

## Dependencies

### Bower packages

The [Bower](http://bower.io) packages are commited to this code base in the `/vendor` directory.

- SlotPicker - for the choose-date-and-time calendar
- GOV.UK Elements - used for UI styles and behaviour
- RespondJS - for responsive IE6 layouts

**Note** SlotPicker requires Modernizr for touch and CSS animation detection. This is part of the SlotPicker package.

### Prison staff info

Currently a private Gem which contains information for booking staff.

## Automated tests

This app uses [RSpec](http://rspec.info/) for Rails tests.

    rake

### Feature tests

#### Locally (using Google Chrome)

    rake spec:features

#### Remotely (using BrowserStack)

You'll need to set the environment variables to tell the tests scripts that you want them to be run remotely.

    export BS_USERNAME browserstack-username
    export BS_PASSWORD browserstack-password
    rake spec:features

#### In parallel

    rake parallel:spec




