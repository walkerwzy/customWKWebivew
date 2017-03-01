//
//  WKWebViewUIDelegate.h
//  test_wkwebview
//
//  Created by walker on 24/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;

@interface WKWebViewUIDelegate : NSObject<WKUIDelegate>
- (instancetype)initWithViewController:(UIViewController *)viewController;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
@end
