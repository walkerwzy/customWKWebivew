//
//  BaseWebViewController.h
//  test_wkwebview
//
//  Created by walker on 09/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

extern NSString * const kWebKitUrlPatternKey;
extern NSString * const kWebKitUrlPatternBlock;
extern NSString * const kWebKitMessageTitle;
extern NSString * const kWebKitMessageHandler;

typedef void (^urlPatternAction)(NSURL *);
typedef void (^messageHandler)(WKScriptMessage *);

@interface BaseWebViewController : UIViewController
@property (nonatomic, strong) NSString  *url;
@property (nonatomic, strong) NSURL     *fileUrl;
@property (nonatomic, strong) NSString  *htmlString;
@property (nonatomic, strong) NSData    *data;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString  *headerJS;
@property (nonatomic, strong) NSString  *footerJS;
@property (nonatomic, copy)   void (^modifyRequest)(NSMutableURLRequest *); // 如果要修改 header 等, 在此做
@property (nonatomic, strong) NSArray<NSDictionary *> *urlPatterns;         // 需要拦截的请求和拦截后的行为组
@property (nonatomic, strong) NSArray<NSDictionary *> *messageHandlers;     // 需要开放给 js 的本地方法组
@property (nonatomic, strong) UIProgressView *progressView;
- (void)loadPage;

@end
