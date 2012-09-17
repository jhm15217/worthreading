chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.executeScript(null, {
    code: "chrome.extension.sendRequest({selection: window.getSelection().toString(), url: document.URL});"});
}); 

function fakePost(text, link) {   
    var form = document.createElement("form");
    form.setAttribute("method", "post");
    form.setAttribute("action", "http://www.worth-reading.org/chrome_extension/new");
    var params = {text: text, link: link};
    for(var key in params) {
        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", key);
        hiddenField.setAttribute("value", params[key]);
        form.appendChild(hiddenField);
    }
    document.body.appendChild(form);
    form.submit();
};

chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  if (request.selection) {
    fakePostCode = fakePost.toString().replace(/(\n|\t)/gm, '');
    chrome.tabs.query({'url': 'http://www.worth-reading.org/chrome_extension/*'}, function(tab) {
      if (tab[0]) {
        chrome.tabs.update(tab[0].id, 
          { 'url': "javascript:" + fakePostCode + "; fakePost('" + request.selection + "', '" + request.url + "');",
            'active': true
        });
      } else {
        chrome.tabs.create({
          'url': "javascript:" + fakePostCode + "; fakePost('" + request.selection + "', '" + request.url + "');"
        });

        // Development mode 
        // chrome.tabs.create({
        //   'url': 'http://localhost:3000/chrome_extension/new?text=' + request.selection 
        //   + '&link=' + request.url 
        // });
      }
      });
  } else  {
    console.log("Unknown request")
  }
});

