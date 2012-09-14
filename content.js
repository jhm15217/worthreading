chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.executeScript(null, {
    code: "chrome.extension.sendRequest({selection: window.getSelection().toString(), url: document.URL});"});
}); 

chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  if (request.selection) {

    chrome.tabs.create({
      'url': 'http://www.worth-reading.org/chrome_extension/new?text=' + request.selection 
      + '&link=' + request.url
    });

    // Development mode 
    // chrome.tabs.create({
    //   'url': 'http://localhost:3000/chrome_extension/new?text=' + request.selection 
    //   + '&link=' + request.url 
    // });
  } else  {
    console.log("Unknown request")
  }
});

