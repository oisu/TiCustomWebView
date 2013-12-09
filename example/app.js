var CustomWebView = require('ti.customwebview');

var win = Ti.UI.createWindow({
    title: 'CustomWebView',
    backgroundColor: '#fff'
});

var webView = CustomWebView.createWebView({
    horizontalScrollEnabled: false, // if true, swipe event is not fired
    html: '<center>Loading, please wait.</center>'
});
webView.addEventListener('scrollStart', function(e) {
    Ti.API.info(e);
});
webView.addEventListener('scroll', function(e) {
    Ti.API.info(e);
});
webView.addEventListener('scrollEnd', function(e) {
    Ti.API.info(e);
});
webView.addEventListener('linkClicked', function(e) {
    Ti.API.info(e);
});
webView.addEventListener('swipeLeft', function(e) {
    Ti.API.info('swipeLeft');
});
webView.addEventListener('swipeRight', function(e) {
    Ti.API.info('swipeRight');
});

win.add(webView);

var nw = Ti.UI.iOS.createNavigationWindow({window: win});
nw.open();

var baseCSS = '<style type="text/css">\
        body {\
            font-family: HelveticaNeue;\
            font-size: 14px;\
            color: #555;\
        }\
        a {\
            color: #099;\
        }\
    </style>\
';

var http = Ti.Network.createHTTPClient({
    onload: function() {
        try {
            var html = [ baseCSS ];
            html.push(this.responseText);
            webView.html = html.join('\n');

        } catch (err) {
            Ti.API.info(err);
        }
    },
    onerror: function(evt) {
        Ti.API.info(evt);
    }
});
http.open('GET', 'http://www.yahoo.com/');
http.send();

