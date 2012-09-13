chrome.browserAction.onClicked.addListener(function(tab) {
  alert(window.getSelection().toString())
  chrome.tabs.create({'url': 'http://localhost:3000/chrome_extension/new?link=' + window.getSelection().toString() + '&subject=' + tab.title }, function(tab) {
  });
//   chrome.tabs.create({'url': 'http://www.worth-reading.org/chrome_extension/new?link=' + tab.url + '&subject=' + tab.title }, function(tab) {
//   });
})
