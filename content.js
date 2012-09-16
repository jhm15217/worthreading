chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.create({'url': 'http://www.worth-reading.org/chrome_extension/new?link=' + tab.url }, function(tab) {
  });
});
