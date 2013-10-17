go_trex = ->
  $('.trex').vapors src: window.trex_image, count_multiplier: 0.5  

go_vapor = ->
  $('.vapors').vapors src: window.vapor_image, count_multiplier: 1
  
jQuery ->
  #this is a hack that makes me sad,  I'm not sure why my objects are colliding.
  window.setTimeout go_vapor, 1
  window.setTimeout go_trex, 500