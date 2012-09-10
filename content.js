chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.create({'url': 'http://www.worth-reading.org/chrome_extension/new'}, function(tab) {
		console.log("Tab opened")
    // Tab opened.
  });
});
