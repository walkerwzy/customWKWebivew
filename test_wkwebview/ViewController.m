//
//  ViewController.m
//  test_wkwebview
//
//  Created by walker on 09/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    urlPatternAction actionA = ^void(NSURL *url) {
        NSLog(@"aaaaa, %@", url);
    };

    urlPatternAction actionB = ^void(NSURL *url) {
        NSLog(@"bbbb, %@", url);
    };
    urlPatternAction actionC = ^void(NSURL *url) {
        NSLog(@"ccc, %@", url);
    };
    
    self.urlPatterns = [NSArray arrayWithObjects:
                              @{kWebKitUrlPatternKey: @".*baidu.*", kWebKitUrlPatternBlock: actionA},
                              @{kWebKitUrlPatternKey: @"sohus", kWebKitUrlPatternBlock: actionB},
                              @{kWebKitUrlPatternKey: @"sina", kWebKitUrlPatternBlock: actionC},
                              nil];
    
    messageHandler method1 = ^void(WKScriptMessage *message) {
//        NSLog(@"method 1, body: %@, %@, %@", [message title1], [message title2], [message title3]);
        NSLog(@"method 1: body: %@", message.body);
    };
    messageHandler log = ^void(WKScriptMessage *message) {
        NSLog(@"%@", message.body);
    };
    self.messageHandlers = @[@{kWebKitMessageTitle: @"m1", kWebKitMessageHandler: method1},
                             @{kWebKitMessageTitle: @"log1", kWebKitMessageHandler: log}];
    self.headerJS = @"alert('header js invoked');";
    self.footerJS = @"appBridge.log1('footer js invoked');";
    
    self.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil]];
    [self loadPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSLog(@"enter");
//    decisionHandler(WKNavigationActionPolicyAllow);
//}


@end
