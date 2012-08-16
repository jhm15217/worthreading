$ ->
  badge_options = 
    animation: true,
    placement: 'bottom',
    trigger: 'hover',
    content: 'No subscribers. Add subscribers by clicking on the subscription list tab.'

  $('#subscription_badge').popover badge_options
