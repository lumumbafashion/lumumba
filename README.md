# LUMUMBA FASHION

Lumumba is a digital clothing platform, we produce urban clothing based on traditional fabrics and cultures found across the world. We open ourselves to our customers so they can interact, design and model for the brand.

We crowdsource designs through culture-themed competitions. Sustainable and transparent sourcing and production.

# DEVELOPERS GUIDE

##Getting Started

+ Clone the application with `git clone https://github.com/kenigbolo/lumumba-prod.git` or use ssh  `git clone git@github.com:kenigbolo/lumumba-prod.git`.

##Dependencies

* Ruby version 2.2.1 and above
* rails 5.0.0

Once you have those two, you can then run your command line and navigate into the project's folder and then run:

* Run `bundle install` to install all other dependencies


    ***Note*** some gems might cause issues while installing, so for unix/linux users try `sudo gem install <gem_name>`
* Run `rails db:migrate` or `rake db:migrate`
* Run `rails db:seed`  or `rake db:seed` to seed the `db` if ne cessary.

(*the `rake` command was used for rails version prior rails 5. But it is no logner required*)

## Running The Server

Due to the use of the `figaro gem` for environment variables used in omniauth the following should be performed when running locally

* Contact the administrator to download the application.yml file [here](www.facebook.com/kenigbolo.meyastephen)
* Put the downloaded `application.yml` file into the `config` folder

You can then run `rails s` or `rails server` and visit the page on the browser by typing `localhost:3000`. (*you can add the flag `-p <port_number>` to specify a different port number, e.i. `rails s -p 8000`*)

##Running The Specs
After all the setting up as mentioned above, you can run the tests. The tests are driven by rspec, capybara and selenium. You can get them fired up by running the following command from the terminal.

  `rspec spec`

or

  `bundle exec rspec`

##Application Main Features

* Authentication (Log in using OAuth)
* E-commerce (Payment integration with Braintree)
* Competitions
* Design showcase
* Blog

##Database
  Uses Postgres in all environments

##License

The Lumumba License (Adopted from Simple Machines License (SMF 1.0 and 1.1))

Copyright (c) 2016 Lumumba


Definitions

 1. This Package is defined as all of the files within any archive
    file or any group of files released in conjunction by Lumumba
    or a derived or modified work based on such files.

 2. A Modification, or a Mod, is defined as instructions, to be
    performed manually or in an automated manner, that alter any part
    of this Package.

 3. A Modified Package is defined as this Package or a derivative of
    it with one or more Modification applied to it.

 4. Distribution is defined as allowing one or more other people to in
    any way download or receive a copy of this Package, a Modified
    Package, or a derivative of this Package.

 5. The Software is defined as an installed copy of this Package, a
    Modified Package, or a derivative of this Package.

 6. The Lumumba Website is defined as
    http://www.lumumba.com/.

Agreement

 1. Permission is hereby granted to use, copy, modify and/or
    distribute this Package, provided that:

    a. All copyright notices within source files and as generated by
       the Software as output are retained, unchanged.

    b. Any Distribution of this Package, whether as a Modified Package
       or not, includes this license and is released under the terms
       of this Agreement. This clause is not dependant upon any
       measure of changes made to this Package.

    c. This Package, Modified Packages, and derivative works may not
       be sold or released under any paid license. Copying fees for
       the transport of this Package, support fees for installation or
       other services, and hosting fees for hosting the Software may,
       however, be imposed.

     d. Any Distribution of this Package, whether as a Modified
        Package or not, requires express written consent from Lumumba.

 2. You may make Modifications to this Package or a derivative of it,
    and distribute your Modifications in a form that is separate from
    the Package, such as patches. The following restrictions apply to
    Modifications:

     a. A Modification must not alter or remove any copyright notices
        in the Software or Package, generated or otherwise.

     b. When a Modification to the Package is released, a
        non-exclusive royalty-free right is granted to Lumumba
        to distribute the Modification in future versions of the
        Package provided such versions remain available under the
        terms of this Agreement in addition to any other license(s) of
        the initial developer.

     c. Any Distribution of a Modified Package or derivative requires
        express written consent from Lumumba.

 3. Permission is hereby also granted to distribute programs which
    depend on this Package, provided that you do not distribute any
    Modified Package without express written consent.


 4. Lumumba reserves the right to change the terms of this
    Agreement at any time, although those changes are not retroactive
    to past releases. Changes to this document will be announced via
    email using the Lumumba email notification list. Failure
    to receive notification of a change does not make those changes
    invalid. A current copy of this Agreement can be found on the
    Lumumba github Readme.

 5. This Agreement will terminate automatically if you fail to comply
    with the limitations described herein. Upon termination, you must
    destroy all copies of this Package, the Software, and any
    derivatives within 48 hours.
