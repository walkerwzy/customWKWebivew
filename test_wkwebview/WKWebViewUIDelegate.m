//
//  WKWebViewUIDelegate.m
//  test_wkwebview
//
//  Created by walker on 24/02/2017.
//  Copyright © 2017 walker. All rights reserved.
//

#import "WKWebViewUIDelegate.h"
@interface WKWebViewUIDelegate()
@property (nonatomic, strong) UIViewController *viewController;
@end
@implementation WKWebViewUIDelegate

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    self.viewController = viewController;
    return self;
}

#pragma mark - ui delegate

/*! @abstract Notifies your app that the DOM window object's close() method completed successfully.
 */
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    
}

/*! @abstract Displays a JavaScript alert panel.
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"runJavaScriptAlertPanelWithMessage:%@", message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"runJavaScriptAlertPanelWithMessage:%@, did clicked", message);
    }];
    [alert addAction:action];
    completionHandler();
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

/*! @abstract Displays a JavaScript confirm panel.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"runJavaScriptAlertPanelWithMessage:%@", message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"runJavaScriptConfirmPanelWithMessage:%@, did clicked", message);
        completionHandler(YES);
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"runJavaScriptConfirmPanelWithMessage:%@, did click cancel", message);
        completionHandler(NO);
    }];
    [alert addAction:action];
    [alert addAction:actionCancel];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

/*! @abstract Displays a JavaScript text input panel.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    NSLog(@"runJavaScriptAlertPanelWithMessage:%@,\ndefaultText:%@", prompt, defaultText);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入";
        if(defaultText){
            textField.text = defaultText;
        }
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"runJavaScriptAlertPanelWithMessage:%@, did clicked", prompt);
        completionHandler(alert.textFields[0].text);
    }];
    [alert addAction:action];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}
@end
