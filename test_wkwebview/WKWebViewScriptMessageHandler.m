//
//  WKWebViewScriptMessageHandler.m
//  test_wkwebview
//
//  Created by walker on 28/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import "WKWebViewScriptMessageHandler.h"
@interface WKWebViewScriptMessageHandler()
@property (nonatomic, copy) messageHandler doAction;
@end
@implementation WKWebViewScriptMessageHandler

- (instancetype)initWithAction:(messageHandler)action {
    self = [super init];
    self.doAction = action;
    return self;
}

/*! @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the
 delegate method.
 @param message The script message received.
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    self.doAction(message);
}

@end
