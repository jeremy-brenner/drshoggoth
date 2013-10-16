go_trex = ->
  $('.trex').vapors src: 'assets/trex.png', count_multiplier: 0.5  

go_vapor = ->
  $('.vapors').vapors src: 'assets/vapor.png', count_multiplier: 1
  
jQuery ->
  #this is a hack that makes me sad,  I'm not sure why my Image() objects are colliding.
  window.setTimeout go_trex, 200
  window.setTimeout go_vapor, 100