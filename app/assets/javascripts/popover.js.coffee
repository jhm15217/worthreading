$ ->
  subscription_badge_options = 
    animation: true,
    placement: 'bottom',
    trigger: 'hover',
    content: 'No subscribers. Add subscribers by clicking on the subscription list tab.'

  add_subscribers_options = 
    animation: true,
    placement: 'bottom',
    trigger: 'focus',
    content: 'Separate email addresses by a comma.'

  $('#subscription_badge').popover subscription_badge_options
  $('#add_subscribers').popover  add_subscribers_options
  $('#first-tutorial').modal 'show'
