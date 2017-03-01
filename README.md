# customWKWebivew
a customer UIViewController with a WKWebview, which handle most js-native mutual invoke, and url interception

# Usage

```
    // url interception
    urlPatternAction actionA = ^void(NSURL *url) {
        NSLog(@"aaaaa, %@", url);
    };

    urlPatternAction actionB = ^void(NSURL *url) {
        NSLog(@"bbbb, %@", url);
    };
    urlPatternAction actionC = ^void(NSURL *url) {
        NSLog(@"ccc, %@", url);
    };
    // pass url-action pairs
    // url pattern can be plain string or regex
    self.urlPatterns = [NSArray arrayWithObjects:
                              @{kWebKitUrlPatternKey: @".*baidu.*", kWebKitUrlPatternBlock: actionA},
                              @{kWebKitUrlPatternKey: @"sohu", kWebKitUrlPatternBlock: actionB},
                              @{kWebKitUrlPatternKey: @"sina", kWebKitUrlPatternBlock: actionC},
                              nil];
    // js invoke native method
    messageHandler method1 = ^void(WKScriptMessage *message) {
        NSLog(@"method 1: body: %@", message.body);
    };
    messageHandler log = ^void(WKScriptMessage *message) {
        NSLog(@"%@", message.body);
    };
    // pass name-action pairs
    self.messageHandlers = @[@{kWebKitMessageTitle: @"m1", kWebKitMessageHandler: method1},
                             @{kWebKitMessageTitle: @"log1", kWebKitMessageHandler: log}];
    // it's also more easy to add start/end js code
    self.headerJS = @"alert('header js invoked');";
    self.footerJS = @"appBridge.log1('footer js invoked');";
    // you can load url, file, string by setting property
    self.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil]];
    [self loadPage];
```
