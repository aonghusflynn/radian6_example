require 'sinatra'
require 'sinatra/contrib/all'
require 'haml'
require 'sass'
require 'coffee_script'
require 'rest_client'
require 'nori'
require 'digest/md5'
require 'json'

class Radian6
  def initialize
    user = 'ccoenen@salesforce.com'
    pass = Digest::MD5.hexdigest 'SFDC1234'
    @key = '7ya9948hm2g32k94dc9sfbcu'
    @url = 'https://api.radian6.com/socialcloud/v1'
    auth = Nori.parse RestClient.get "#{@url}/auth/authenticate", {
      "auth_appkey" => @key,
      "auth_user"   => user,
      "auth_pass"   => pass
    }
    @token = auth['auth']['token']
  end
  
  @@instance = Radian6.new
  
  def self.instance
    @@instance
  end
  
  def widget(id)
    false unless id
    Nori.parse RestClient.get "#{@url}/data/widget/#{id}", {
      'auth_token' => @token,
      'auth_appkey' => @key
    }
  end
end

if development?
  require 'rack-livereload'
  require 'sinatra/reloader'
  use Rack::LiveReload
end

configure do
  $stdout.sync = true
  
  set :app_file, __FILE__
  set :port, ENV['PORT']
  set :public_folder, File.expand_path(File.join(File.dirname(__FILE__), 'public'))
  enable :inline_templates
end

get '/' do
  haml :index
end

get '/widget/:id' do
  Radian6.instance.widget(params[:id]).to_json
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
    %meta{ :charset => "utf-8" }
    %meta{ "http-equiv" => "X-UA-Compatible", :content => "IE=edge,chrome=1" }
    
    %title Ferrero
    %meta{ :name => "author", :content => "Thomas Stachl" }
    %meta{ :name => "description", :content => "Ferrero Radian6 Demo" }
    %meta{ :name => "viewport", :content => "width=device-width, initial-scale=1.0" }

    %link{ :href => "/stylesheet.css", :media => "all", :rel => "stylesheet" }
    
  %body
    %header
      .r6logo
      %h1
        %img{ :src => '/images/ferrero_logo.png', :alt => 'Ferrero' }
        %small 
          High quality, 
          .smaller crafted precision
    .wrapper
      = yield
    %footer
    
    %script{ :src => '//www.google.com/jsapi' }
    :javascript
      google.load('jquery', '1.7.1')
      google.load('visualization', '1.0', {
        'packages': ['corechart']
      })
    %script{ :src => '/application.js' }
    :javascript
      var Ferrero = new Application()
      var _gaq=[["_setAccount","UA-XXXXX-X"],["_trackPageview"],["_trackPageLoadTime"]];
      (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];g.async=1;
      g.src=("https:"==location.protocol?"//ssl":"//www")+".google-analytics.com/ga.js";
      s.parentNode.insertBefore(g,s)}(document,"script"));

@@ index
#brands
  %img{ :src => '/images/conversation_header.png', :height => 65, :width => 580 }
  .radian6{ 'data-url' => '/widget/1595263638', 'data-type' => 'area' }

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

article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section
  display: block

ol, ul
  list-style: none

blockquote, q
  quotes: none

blockquote:before, blockquote:after,
q:before, q:after
  content: ''
  content: none

table
  border-collapse: collapse
  border-spacing: 0

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
      small
        display: block
        padding-top: 7px
        color: #1F0E00
        text-transform: uppercase
        font-size: 120%
        .smaller
          font-size: 75%
  
  .wrapper
    #brands
      background: #E5E5E5
      border-top: #C4C4C4 solid 1px
      border-bottom: #C4C4C4 solid 1px
      margin-top: 20px
      padding: 20px
      min-height: 270px

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
    data = data.widgetOutput.dataitems.dataitem.graphData
    
    @data = new google.visualization.DataTable();
    @data.addColumn 'date', 'Date'
    @data.addColumn 'number', name for name in @extractWords data.sphinxInfo.info
    
    @data.addRows data.dataPoint.length
    for index, dataPoint of data.dataPoint
      @data.setValue parseInt(index), 0, new Date(dataPoint['@actual'])
      for key, value of dataPoint.plot
        @data.setValue parseInt(index), parseInt(key) + 1, parseInt(value)
    
    @chart = new google.visualization[@getType()](@el.get(0))
    @hideLoading()
    @chart.draw @data, @settings
  
  getType: ->
    switch (@settings.type or '').toLowerCase()
      when 'area', 'areachart'
        'AreaChart'
      when 'bubble', 'bubblechart'
        'BubbleChart'
      when 'geo', 'geochart'
        'GeoChart'
      else
        'LineChart'
        
  
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

class @Application
  constructor: ->
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