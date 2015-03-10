###
Vapors jQuery Plugin v1.0 
Release: 9/10/2013
Author: Jeremy Brenner <jeremyjbrenner@gmail.com>

http://github.com/jeremy-brenner

Licensed under the WTFPL license: http://www.wtfpl.net/txt/copying/
###

$ = jQuery # we are already anonymous, no need to wrap again

class jQueryPlugin
  name: 'plugin-name'
  default_method: 'start'
  defaults: {}

  constructor: ( target, options ) ->
    @$target = $(target)    
    @options = @defaults
    
    obj = @$target.data @name
    unless obj # append self or use current
      @$target.data @name, obj = @ 

    obj._called options

  _called: ( options = {} ) ->
    method = @default_method
    if typeof options == 'string'
      method = options
    else
      @options = $.extend {}, @options, options

    @[method]()

class VaporAnimation extends jQueryPlugin
  name: 'vapors'

  defaults: 
    count_multiplier: 1
    min_speed: 60 #pixels per second
    max_speed: 120
    src: false 

  _vapors: []

  defaultCount: ->
    @options.count or Math.floor @viewSize() / ( @options.image.width * @options.image.height ) * @options.count_multiplier 

  viewSize: () ->
    @leastOf @boxSize($(window)), @boxSize(@$target)

  boxSize: ($box) ->
    $box.outerWidth() * $box.outerHeight() 

  leastOf: ( first, second ) ->
    if ( first < second ) then first else second


  start: =>
    @ready = false
    @$canvas = $("<canvas>").css
      position: 'absolute',
      top: 0,
      left: 0,
      'z-index': 0

    @$target.append @$canvas
    @canvas = @$canvas[0]
    @context = @canvas.getContext "2d"
    @options.image = new Image()
    @options.image.onload = @startAnimation
    @options.image.src = @options.src
    @timer = new Timer()

  startAnimation: =>
    @updateVapors()
    $(window).on 'resize', @updateVapors
    window.requestAnimationFrame @drawFrame

  drawFrame: (timestep) =>
    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    vapor.draw(timestep) for vapor in @_vapors
    @timer.tick(timestep)
    window.requestAnimationFrame @drawFrame

    
  updateVapors: =>
    @canvas.width = @$target.outerWidth()
    @canvas.height = @$target.outerHeight()
    newvapes = @defaultCount() - @_vapors.length
    if newvapes > 0 
      @_vapors.push new Vapor(@canvas, @options) for i in [0...newvapes]

    if newvapes < 0
      start = @_vapors.length + newvapes
      @_vapors[i].destroy() for i in [start...@_vapors.length]
      @_vapors = @_vapors[0...start]


  stop: ->
    v.destroy() for v in @_vapors
    @_vapors = []  


class Vapor
  constructor: ( canvas, options ) ->
    @options = options
    @canvas = canvas
    @context = @canvas.getContext "2d"
 
  reset: (t) ->
    @starttime = t 
    @angle = Math.floor Math.random() * 360
    @rotation_speed = Math.floor Math.random() - 0.5
    @start_scale = Math.random() + 1
    @xpos = @startLeft()
    @starty = @startTop(t)
    @speed = @randomPPS()

  delta: (t) ->
    t - @starttime

  ypos: (t) ->    
    @starty - @speed * @delta(t) / 1000 
   
  rotation_angle: (t) ->
    @angle + @rotation_speed * @delta(t) / 50

  rotation_rads: (t) ->
    @rotation_angle(t) * Math.PI/180

  rotation_sin: (t) ->
    Math.sin @rotation_rads(t)

  rotation_cos: (t) ->
    Math.cos @rotation_rads(t)
  
  scale: (t) ->
    @start_scale + @delta(t) / 10000

  randomPPS: ->
    Math.floor Math.random() * (@options.max_speed - @options.min_speed) + @options.min_speed

  startTop: (t) ->
    @canvas.height + @height(t)

  endTop: (t) ->
    0 - @height(t)

  maxLeft: ->
    @canvas.width #- @width()

  startLeft: ->
    Math.floor @maxLeft() * Math.random() 

  width: (t) ->
    @options.image.width * @scale(t)

  height: (t) ->
    @options.image.height * @scale(t)

  draw: (t) ->
    if @ypos(t) < @endTop(t) or not @starttime
      @reset(t)
    @context.setTransform @rotation_cos(t), @rotation_sin(t), -@rotation_sin(t), @rotation_cos(t), @xpos, @ypos(t)
    @context.drawImage @options.image, -@width(t)/2, -@height(t)/2, @width(t), @height(t)
  
  #  @context.save()
  #  @context.translate @xpos, @ypos(t)
  #  @context.rotate @rotation_rads(t)
  #  @context.drawImage @options.image, -(@width(t)/2), -(@height(t)/2), @width(t), @height(t)
  #  @context.restore()

  destroy: ->

class Timer
  constructor: ->
    @start_time = false
    @frame_count = 0

  tick: (t) ->
    @start_time ||= t
    @frame_count++
    if t - @start_time > 1000
      @frame_rate(t)
      @start_time = t
      @frame_count = 0

  frame_rate: (t) ->
    elapsed = ( t - @start_time ) / 1000
    rate = @frame_count / elapsed
    console.log "#{@frame_count} frames in #{elapsed} seconds, #{rate} fps."

$.fn.vapors = (options) ->
  @each ->
    new VaporAnimation(@,options) 

