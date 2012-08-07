Radian6 Example
===============

This is an example showing how you can leverage the Radian6 API to show your dashboard widgets to the world.

Requirements
------------

In addition to the files in this repository you might want to create a `.env` file with the following contents:

    PORT=3000
    RACK_ENV=development
    RADIAN6_USER=you@example.com
    RADIAN6_PASS=YourStrongPassword
    RADIAN6_KEY=YourAPIKey

You should also change the widget ids to your own.

    Line 125:
    @@ index
    #brands
      %img{ :src => '/images/conversation_header.png', :height => 65, :width => 580 }
      .radian6{ 'data-url' => '/widget/1595263638', 'data-type' => 'area' }
    #number
      .radian6{ 'data-url' => '/widget/1595269472', 'data-type' => 'number' }
      .label Total number of social conversations analysed.
    .searchbubble
      #pie
        .radian6{ 'data-url' => '/widget/1595388509', 'data-type' => 'pie' }
      #search
        .radian6#searchresults{ 'data-url' => '/widget/1595387168', 'data-type' => 'cloud' }
    #map
      .conv_bubble
      .radian6{ 'data-url' => '/widget/1595388567', 'data-type' => 'geo' }

    #hash
      .radian6#hashtags{ 'data-url' => '/widget/1595388463', 'data-type' => 'bar' }

Once created and changed you can initialize a local demo by using the following commands:

    $ bundle install
    ...
    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
    $ foreman start
    12:48:44 web.1   | started with pid 35267
    12:48:44 guard.1 | started with pid 35268
    ...

Now you can point your browser to `http://localhost:3000`

Heroku
------

    $ heroku create
    Created sushi.herokuapp.com | git@heroku.com:sushi.git
    
    $ heroku config:add heroku config:add RADIAN6_USER=you@example.com RADIAN6_PASS=YourStrongPassword RADIAN6_KEY=YourAPIKey
    Setting config vars and restarting sushi... done, v
    
    $ heroku addons:add memcache:5mb
    ...
    
    $ git push heroku master
    -----> Heroku receiving push
    ...
