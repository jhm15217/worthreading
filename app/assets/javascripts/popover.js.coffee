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
    content: 'Be sure to separate email addresses by a ", "(a comma and a space)'

  $('#subscription_badge').popover subscription_badge_options
  $('#add_subscribers').popover  add_subscribers_options
  $('#first-tutorial').modal 'show'
