//
//  WKWebViewScriptMessageHandler.h
//  test_wkwebview
//
//  Created by walker on 28/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseWebViewController.h"

@interface WKWebViewScriptMessageHandler : NSObject<WKScriptMessageHandler>
- (instancetype)initWithAction:(messageHandler)action;
- (instancetype)init NS_UNAVAILABLE;
@end
