chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.executeScript(null,
                           {code: "chrome.extension.sendRequest({selection: window.getSelection().toString()});"});
}); 

chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  if (request.selection) {
    alert(request.selection)
  } else  {
    alert("Nothing")
  }
});

