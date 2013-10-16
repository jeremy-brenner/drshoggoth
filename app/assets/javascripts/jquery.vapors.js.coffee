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
    min_speed: 50 #pixels per second
    max_speed: 200
    fade_in_perc: .40  # fraction of time to spend fading in and out
    fade_out_perc: 0 
    img: false 

  _vapors: []

  defaultCount: ->
    @options.count or Math.floor @viewSize() / ( @options.image.width * @options.image.height ) * @options.count_multiplier 

  viewSize: () ->
    @leastOf @boxSize($(window)), @boxSize(@$target)

  boxSize: ($box) ->
    $box.width() * $box.height() 

  leastOf: ( first, second ) ->
    if ( first < second ) then first else second

  randId: ->
    "vape_can_#{Math.floor(Math.random()*100000)}"

  start: =>
    @ready = false
    @$canvas = $("<canvas id=#{@randId()}>").css
      position: 'absolute',
      top: 0,
      left: 0,
      'z-index': 0

    @$target.append @$canvas
    @canvas = @$canvas[0]
    @options.image = $(@options.img)[0]
    if @options.image.complete
      @startAnimation() 
    else
      @options.image.onload = @startAnimation

  startAnimation: =>
    @updateVapors()
    $(window).on 'resize', @updateVapors
    window.requestAnimationFrame @drawFrame

  drawFrame: (timestep) =>
    @canvas.width = @$target.width()
    @canvas.height = @$target.height()
    vapor.draw(timestep) for vapor in @_vapors
    window.requestAnimationFrame @drawFrame

  updateVapors: =>
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
    @angle = Math.random() * 360
    @rotation_speed = Math.random() - 0.5
    @start_scale = Math.random() + 1
    @xpos = @startLeft()
    @starty = @startTop(t)
    @speed = @randomPPS()

  delta: (t) ->
    t - @starttime

  ypos: (t) ->    
    Math.floor( @starty - @speed * @delta(t) / 1000 )
   
  rotation: (t) ->
    @angle + @rotation_speed * @delta(t) / 50
  
  scale: (t) ->
    @start_scale + @delta(t) / 10000

  randomPPS: ->
    Math.random() * (@options.max_speed - @options.min_speed) + @options.min_speed

  startTop: (t) ->
    @canvas.height + @height(t)

  endTop: (t) ->
    0 - @height(t)

  maxLeft: ->
    @canvas.width #- @width()

  startLeft: ->
    Math.floor @maxLeft() * Math.random() 

  fadeInTime: ->
    @duration * @options.fade_in_perc

  fadeOutTime: ->
    @duration * @options.fade_out_perc

  width: (t) ->
    @options.image.width * @scale(t)

  height: (t) ->
    @options.image.height * @scale(t)

  draw: (t) ->
    if @ypos(t) < @endTop(t) or not @starttime
      @reset(t)
    @context.save()
    @context.translate @xpos, @ypos(t)
    @context.rotate @rotation(t) * Math.PI/180
    @context.drawImage @options.image, -(@width(t)/2), -(@height(t)/2), @width(t), @height(t)
    @context.restore()

  destroy: ->


$.fn.vapors = (options) ->
  @each ->
    new VaporAnimation(@,options) 

