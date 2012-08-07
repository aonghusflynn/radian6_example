require 'sinatra'
require 'sinatra/contrib/all'
require 'haml'
require 'sass'
require 'coffee_script'
require 'rest_client'
require 'nori'
require 'digest/md5'
require 'json'
require 'dalli'

class Radian6
  def initialize
    @url   = 'https://api.radian6.com/socialcloud/v1'
    @token = Nori.parse(RestClient.get("#{@url}/auth/authenticate", {
      'auth_appkey' => ENV['RADIAN6_KEY'],
      'auth_user'   => ENV['RADIAN6_USER'],
      'auth_pass'   => Digest::MD5.hexdigest(ENV['RADIAN6_PASS'])
    }))['auth']['token']
  end
  
  @@instance = Radian6.new
  
  def self.instance
    @@instance
  end
  
  def widget(id)
    false unless id
    Nori.parse RestClient.get "#{@url}/data/widget/#{id}", {
      'auth_token' => @token,
      'auth_appkey' => ENV['RADIAN6_KEY']
    }
  end
end

if development?
  require 'rack-livereload'
  require 'sinatra/reloader'
  use Rack::LiveReload
  $stdout.sync = true
end

configure do
  set :app_file, __FILE__
  set :port, ENV['PORT']
  set :public_folder, File.expand_path(File.join(File.dirname(__FILE__), 'public'))
  set :cache, Dalli::Client.new(ENV['MEMCACHE_SERVERS'], :username => ENV['MEMCACHE_USERNAME'], :password => ENV['MEMCACHE_PASSWORD'], :expires_in => 3600) if production?
  enable :inline_templates
end

helpers do
  def cache(key, &block)
    if production?
      unless settings.cache.get key
        settings.cache.set key, yield(key)
      end
      settings.cache.get key
    else
      yield key
    end
  end
end

get '/' do
  haml :index
end

get '/widget/:id' do
  cache(params[:id]) do |key|
    Radian6.instance.widget(key).to_json
  end
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/application.js' do
  content_type 'text/javascript', :charset => 'utf-8'
  coffee :javascript
end

__END__

@@ layout
!!! 5
%html{ :lang => "en" }
  %head
    %title Ferrero
    %meta{ :charset => "utf-8" }
    %meta{ "http-equiv" => "X-UA-Compatible", :content => "IE=edge,chrome=1" }
    %meta{ :name => "author", :content => "Thomas Stachl" }
    %meta{ :name => "description", :content => "Ferrero Radian6 Demo" }
    %meta{ :name => "viewport", :content => "width=device-width, initial-scale=1.0" }

    %link{ :href => "/stylesheet.css", :media => "all", :rel => "stylesheet" }
    
  %body
    %header
      .r6logo
      %h1
        %img{ :src => '/images/ferrero_logo.png', :alt => 'Ferrero' }
    .wrapper
      = yield
    %footer
    
    %script{ :src => '//www.google.com/jsapi' }
    :javascript
      google.load('jquery', '1.7.1')
      google.load('visualization', '1.0', {
        'packages': ['corechart', 'geochart']
      })
      google.load('webfont', '1.0.28')
    %script{ :src => '/js/cloud.js' }
    %script{ :src => '/application.js' }
    - if production?
      :javascript
        var _gaq=[["_setAccount","UA-32104003-4"],["_trackPageview"],["_trackPageLoadTime"]];
        (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];g.async=1;
        g.src=("https:"==location.protocol?"//ssl":"//www")+".google-analytics.com/ga.js";
        s.parentNode.insertBefore(g,s)}(document,"script"));

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

@@ stylesheet
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed, 
figure, figcaption, footer, header, hgroup, 
menu, nav, output, ruby, section, summary,
time, mark, audio, video
  margin: 0
  padding: 0
  border: 0
  font-size: 100%
  font: inherit
  vertical-align: baseline

body
  line-height: 1
  width: 617px
  margin: 0 auto
  font-family: arial, sans-serif
  
  header
    background-image: url(/images/header_bg.png)
    background-position: bottom left
    background-repeat: repeat-x
    height: 184px
    padding: 20px
    margin-bottom: 20px
    
    .r6logo
      background: transparent url(/images/r6logo.png) top left no-repeat
      height: 51px
      width: 167px
    
    h1
      margin-top: 60px
      height: 50px
      img
        float: left
        margin-right: 20px
  
  .wrapper
    #brands
      background: #E5E5E5
      border-top: #C4C4C4 solid 1px
      border-bottom: #C4C4C4 solid 1px
      padding: 20px
      min-height: 270px
      margin-bottom: 20px
    
    #number
      height: 70px
      padding: 20px
      background: #a3591d
      background: -moz-linear-gradient(top,  #a3591d 0%, #e4872c 100%)
      background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#a3591d), color-stop(100%,#e4872c))
      background: -webkit-linear-gradient(top,  #a3591d 0%,#e4872c 100%)
      background: -o-linear-gradient(top,  #a3591d 0%,#e4872c 100%)
      background: -ms-linear-gradient(top,  #a3591d 0%,#e4872c 100%)
      background: linear-gradient(to bottom,  #a3591d 0%,#e4872c 100%)
      filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#a3591d', endColorstr='#e4872c',GradientType=0 )
      border-top: #B3B3B3 solid 1px
      border-bottom: #B3B3B3 solid 1px
      -moz-box-shadow: 0 0 5px #B3B3B3
      -webkit-box-shadow: 0 0 5px #B3B3B3
      box-shadow: 0 0 5px #B3B3B3
      margin-bottom: 20px
      color: #33180D
      font-size: 115%
      
      .radian6
        color: white
        font-size: 300%
        float: left
        margin-right: 45px
        font-family: 'Holtwood One SC', serif
        margin-top: 10px
      
      .label
        line-height: 25px
        margin-top: 15px

    .searchbubble
      height: 301px
      background: transparent url(/images/table_bg.png) top left no-repeat
      position: relative
      margin-bottom: 20px
    
    #pie
      position: absolute
      height: 300px
      width: 280px
      margin-left: 27px

    #search
      position: absolute
      height: 245px
      width: 245px
      left: 340px
      top: 15px
      .radian6
        height: 245px
        width: 245px

    #map
      position: relative
      margin-bottom: 20px
      height: 388px
      .conv_bubble
        height: 66px
        width: 109px
        position: absolute
        top: 20px
        left: 20px
        background: transparent url(/images/conv_bubble.png) top left no-repeat
        z-index: 1
    
    #hash
      background: transparent url(/images/hashtags_bg.png) 20px 0 no-repeat
      height: 273px
      margin-bottom: 20px
      position: relative
      .radian6
        height: 250px
        width: 535px
        position: absolute
        top: 10px
        left: 40px

.loading
  height: 80px
  width: 100%
  background-image: url(/images/propeller.gif)
  background-position: 50% 50%
  background-repeat: no-repeat

@@ javascript
$ = jQuery.noConflict()

class Widget
  constructor: (@el, options = {}) ->
    @settings = $.extend
      url: @el.data 'url'
      type: @el.data 'type'
    , options
    
    if @settings.url?
      $.getJSON @settings.url, $.proxy(@, 'init')
    if @settings.data?
      @init @settings.data
    
    @showLoading()
  
  init: (data) ->  
    if @settings.dataCallback?
      @settings.dataCallback.call this, data
    if @settings.type == 'number'
      return @el.empty().text(data.widgetOutput.dataitems['@postcount'])
    if @settings.type == 'cloud'
      return @renderCloud(data)
    
    @hideLoading()
    @chart = new google.visualization[@getType()](@el.get(0))
    delete @settings.type
    @chart.draw(@data, @settings)
  
  getType: ->
    switch (@settings.type or '').toLowerCase()
      when 'area', 'areachart'
        'AreaChart'
      when 'bubble', 'bubblechart'
        'BubbleChart'
      when 'geo', 'geochart'
        'GeoChart'
      when 'bar', 'barchart'
        'BarChart'
      when 'pie', 'piechart'
        'PieChart'
      else
        'LineChart'
  
  renderCloud: () ->
    @el.empty()
    for item in @data
      @el.append '<span data-weight="' + item.value + '">' + item.word + '</span>'
    @el.awesomeCloud @settings
  
  extractWords: (arr) ->
    arr.map (val, idx) ->
      val['@word'].split('"')[1]
  
  showLoading: ->
    if @el.find('.loading').size() is 0
      @el.append(
        '<div class="loading">'
      )
    @el.find('.loading').show()
  
  hideLoading: ->
    @el.find('.loading').hide()

$.fn.radian6 = (options = {}) ->
  @each (i, el) ->
    data = $(@).data 'radian6'
    $(@).data 'radian6', (data = new Widget($(@), options)) unless data
    if typeof options == 'string'
      data[options].apply @, Array.prototype.slice.call(arguments, 1)

$.fn.radian6.Constructor = Widget

WebFont.load
  google:
    families: ['Holtwood+One+SC::latin']
    
$ ->
  $('#brands .radian6').radian6
    height: 197
    chartArea:
      left: 50
      top: 10
      width: 530
      height: 132
    backgroundColor: '#E5E5E5'
    colors: ['white', '#88070C', '#DAC880', '#16732E', '#BF1919']
    legend:
      position: 'top'
    hAxis:
      baseline: 0
      slantedText: true
    vAxis:
      baselineColor: '#FA8A28'
      gridlines:
        color: '#FA8A28'
    dataCallback: (data) ->
      data = data.widgetOutput.dataitems.dataitem.graphData
      @data = new google.visualization.DataTable()
      @data.addColumn 'date', 'Date'
      @data.addColumn 'number', name for name in @extractWords data.sphinxInfo.info

      @data.addRows data.dataPoint.length
      $.each data.dataPoint, (index, dataPoint) =>
        @data.setValue parseInt(index), 0, new Date(dataPoint['@actual'])
        $.each dataPoint.plot, (key, value) =>
          @data.setValue parseInt(index), parseInt(key) + 1, parseInt(value)
    
  $('#number .radian6').radian6()
  $('#map .radian6').radian6
    colorAxis:
      minValue: 0
      colors: ['#d39c4e', '#4b2425']
    dataCallback: (data) ->
      data = data.widgetOutput.dataitems.dataitem
      arr = []
      arr.push ['Country', 'Total Count']
      for value in data.value
        arr.push [value.label, parseInt(value.count)]
      @data = google.visualization.arrayToDataTable arr
  $('#hash .radian6').radian6
    backgroundColor: 'transparent'
    height: 250
    legend:
      position: 'none'
    colors: ['#33180D']
    dataCallback: (data) ->
      data = data.widgetOutput.dataitems.dataitem.filter (item) ->
        parseInt(item.value.count) > 0
      arr = []
      arr.push ['Hash Tag', 'Count']
      for item in data
        arr.push [item.name, parseInt(item.value.count)]
      @data = google.visualization.arrayToDataTable arr
  $('#search .radian6').radian6
    size:
      grid: 16
      factor: 0
      normalize: false
    color:
      start: '#d39c4e'
      end: '#4b2425'
    options:
      color: 'gradient'
      rotationRatio: 0.2
      printMultiplier: 3
      sort: 'highest'
    font: 'Helvetica, Arial, sans-serif'
    shape: 'square'
    dataCallback: (data) ->
      data = data.widgetOutput.dataitems.dataitem
      @data = []
      for item in data
        if item.key? and item.value?
          @data.push
            word: item.key.split('"')[1]
            value: item.value
  $('#pie .radian6').radian6
    backgroundColor: 'transparent'
    width: 280
    height: 300
    colors: ['#2c190a', '#4b2425', '#845f49', '#c4962e', '#c99b34', '#f2c76a', '#f0a62d', '#d5c979', '#d7b980', '#d39c4e']
    legend:
      position: 'none'
    hAxis:
      textPosition: 'none'
      baselineColor: 'transparent'
      gridlines:
        color: 'transparent'
      minValue: 10
      maxValue: 120
      viewWindowMode: 'pretty'
    vAxis:
      textPosition: 'none'
      baselineColor: 'transparent'
      gridlines:
        color: 'transparent'
      minValue: 10
      maxValue: 120
      viewWindowMode: 'pretty'
    chartArea:
      left: 10
      width: 260
      height: 300
    sizeAxis:
      maxSize: 60
      minSize: 20
    dataCallback: (data) ->
      data = data.widgetOutput.dataitems.dataitem
      arr = []
      arr.push ['Source', 'Count']
      for item in data.value
        arr.push [item.label, parseInt(item.count)]
      @data = google.visualization.arrayToDataTable arr