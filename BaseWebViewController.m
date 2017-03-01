//
//  BaseWebViewController.m
//  test_wkwebview
//
//  Created by walker on 09/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import "BaseWebViewController.h"
#import "WKWebViewUIDelegate.h"
#import "WKWebViewScriptMessageHandler.h"

NSString * const kWebKitUrlPatternKey       = @"pattern";
NSString * const kWebKitUrlPatternBlock     = @"block";
NSString * const kWebKitMessageTitle        = @"title";
NSString * const kWebKitMessageHandler      = @"method";

@interface BaseWebViewController ()<WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WKWebViewUIDelegate *UIDelegate;
@property (nonatomic, strong) NSMutableArray<WKWebViewScriptMessageHandler *> *messageHandlerObjs;
@end

@implementation BaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)setUrl:(NSString *)url {
    if(_url) return;
    _url = url;
}

- (void)setData:(NSData *)data {
    if(_data) return;
    _data = data;
}

- (void)setFileUrl:(NSURL *)fileUrl {
    if(_fileUrl) return;
    _fileUrl = fileUrl;
}

- (void)setHtmlString:(NSString *)htmlString {
    if(_htmlString) return;
    _htmlString = htmlString;
}

- (void)loadPage {
    if(self.htmlString) {
        [self.webView loadHTMLString:self.htmlString baseURL:nil];
    }else if(self.fileUrl){
        [self.webView loadFileURL:self.fileUrl allowingReadAccessToURL:self.fileUrl];
    }else if(self.data) {
        // 待实现
        // [self.webView loadData:self.data MIMEType:@"text/html" characterEncodingName:@"UTF-8" baseURL:nil];
    }else{
        // 生产中主要是这种用法
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        NSString* wzcookie = [NSString stringWithFormat:@"%@=%@",@"__wyt__", @"token"];
        [request addValue:wzcookie forHTTPHeaderField:@"Cookie"];
        self.modifyRequest(request);
        [self.webView loadRequest:request];
    }
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WKWebViewUIDelegate *)UIDelegate {
    if(!_UIDelegate) {
        _UIDelegate = [[WKWebViewUIDelegate alloc] initWithViewController:self];
    }
    return _UIDelegate;
}

- (WKWebView *)webView {
    if(!_webView){
        // configurations
        // inject js
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        if(self.headerJS) {
            WKUserScript *headerJS = [[WKUserScript alloc] initWithSource:self.headerJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
            [config.userContentController addUserScript:headerJS];
        }
        
        // script message handler
        if(self.messageHandlers.count > 0) {
            NSMutableString *appBridge = [NSMutableString stringWithString:@"var appBridge={};\n"];
            _messageHandlerObjs = [NSMutableArray arrayWithCapacity:self.messageHandlers.count];
            [self.messageHandlers enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *title = [obj objectForKey:kWebKitMessageTitle];
                messageHandler handler = [obj objectForKey:kWebKitMessageHandler];
                WKWebViewScriptMessageHandler *handlerObj = [[WKWebViewScriptMessageHandler alloc] initWithAction:handler];
                [self.messageHandlerObjs addObject:handlerObj]; // retrain it.
                [config.userContentController addScriptMessageHandler:handlerObj name:title];
                
                // 为了使用方便, 以及与可能的安卓版调用方式一致, 把方法调用封装一下
                NSString *str_function = [NSString stringWithFormat:@"function(params){window.webkit.messageHandlers.%@.postMessage(params);}\n", title];
                [appBridge appendFormat:@"appBridge.%@=%@", title, str_function];
            }];
            // 注意这里, 我认为有人可能在 footerJS 里面调appBridge里的方法, 所以特意把它写到了bridge后面
            if(self.footerJS) {
                [appBridge appendString:self.footerJS];
            }
            [config.userContentController addUserScript:[[WKUserScript alloc] initWithSource:appBridge
                                                                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                                            forMainFrameOnly:YES]];
        }
        
        // init
        CGRect frame = [[UIScreen mainScreen] bounds];
        _webView = [[WKWebView alloc] initWithFrame:frame configuration:config];
        _webView.UIDelegate = self.UIDelegate;
        _webView.navigationDelegate = self;
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:_webView];
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [_webView addSubview:self.progressView];
    }
    return _webView;
}


#pragma mark - navigation delegate

/*! @abstract Decides whether to allow or cancel a navigation.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"decidePolicyForNavigationAction:%@", navigationAction.request.URL.absoluteString);
    NSString *url = navigationAction.request.URL.absoluteString;
    [self.urlPatterns enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *pattern = [obj objectForKey:kWebKitUrlPatternKey]; // url 拦截的关键字或正则表达式
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", pattern];
        urlPatternAction handler = [obj objectForKey:kWebKitUrlPatternBlock];
        if([url containsString:pattern] || [predicate evaluateWithObject:url]){
            decisionHandler(WKNavigationActionPolicyCancel);
            handler(navigationAction.request.URL);
            *stop = YES;
        }
    }];
    decisionHandler(WKNavigationActionPolicyAllow);
}

/*! @abstract Decides whether to allow or cancel a navigation after its response is known.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"decidePolicyForNavigationResponse:%@", navigationResponse.response);
//    NSLog(@"decidePolicyForNavigationResponseWithCode:%ld", ((NSHTTPURLResponse *)navigationResponse.response).statusCode);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/*! @abstract Invoked when a main frame navigation starts.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
}

/*! @abstract Invoked when a server redirect is received for the main
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation:error:%@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/*! @abstract Invoked when content starts arriving for the main frame.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didCommitNavigation");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

/*! @abstract Invoked when a main frame navigation completes.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didFinishNavgation");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation:error%@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/*! @abstract Invoked when the web view's web content process is terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"webViewWebContentProcessDidTerminate");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - WKWebview KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        NSLog(@"%f", self.webView.estimatedProgress);
        // estimatedProgress is a value from 0.0 to 1.0
        // Update your UI here accordingly
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
}


- (void)dealloc {
    if ([self isViewLoaded]) {
        [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    
    // if you have set either WKWebView delegate also set these to nil here
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"runJavaScriptAlertPanelWithMessage:%@", message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"runJavaScriptAlertPanelWithMessage:%@, did clicked", message);
    }];
    [alert addAction:action];
    completionHandler();
    [self presentViewController:alert animated:YES completion:nil];
}

@end
