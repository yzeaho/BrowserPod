#import "BrowserController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "MediaType.h"
#import "AppNavigationBar.h"
#import "FileLookController.h"

@interface BrowserController ()<WKNavigationDelegate, WKUIDelegate, AppNavigationBarDelegate>

@property (nonatomic, strong) UILabel *textView;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation BrowserController

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    
    _appNavigationBar = [[AppNavigationBar alloc] init:self.navigationController.navigationBar title:@""];
    _appNavigationBar.delegate = self;
     [self.view addSubview:_appNavigationBar];
    
    _textView = [[UILabel alloc] init];
    _textView.frame = CGRectZero;
    _textView.textAlignment = NSTextAlignmentCenter;
    _textView.hidden = YES;
    _textView.font = [UIFont systemFontOfSize:18];
    _textView.numberOfLines = 0;
    [self.view addSubview:_textView];
    
    //init wkwebview
    CGRect rect = CGRectMake(0, _appNavigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _appNavigationBar.frame.size.height);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [BrowserController sharedProcessPool];
    _webView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    _webView.allowsBackForwardNavigationGestures = NO;
    _webView.navigationDelegate = self;
    //_webView.UIDelegate = self;
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    DDLogInfo(@"load %@", _htmlUrl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_htmlUrl];
    [_webView loadRequest:request];
    [self.view addSubview: _webView];
}

- (void)navigationBarGoToBack {
    if (_webView.hidden == NO && [_webView canGoBack]) {
        DDLogDebug(@"webview goBack");
        [_webView goBack];
    } else {
        DDLogDebug(@"goToBack");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

+ (WKProcessPool*)sharedProcessPool {
    static WKProcessPool *processPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!processPool) {
            processPool = [[WKProcessPool alloc] init];
        }
    });
    return processPool;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            NSString *title = self.webView.title;
            DDLogInfo(@"title:%@", title);
            if (title && title.length > 0) {
                _appNavigationBar.titleView.text = title;
                self.title = title;
            } else {
                NSURL *url = self.webView.URL;
                title = url.lastPathComponent;
                _appNavigationBar.titleView.text = title;
                self.title = title;
            }
            return;
        }
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)popViewcontrollerFunc {
    DDLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    DDLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    DDLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    DDLogInfo(@"%@", error);
    // Frame load interrupted
    if (error.code == 102 && [error.domain isEqualToString:@"WebKitErrorDomain"]) {
        return;
    }
    [self showError:error];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    DDLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    DDLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    DDLogInfo(@"%@", error);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    DDLogInfo(@"%@", navigationAction);
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url.scheme lowercaseStringWithLocale:[NSLocale currentLocale]];
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        if (navigationAction.targetFrame == nil || navigationAction.targetFrame.mainFrame == NO) {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([scheme isEqualToString:@"about"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([scheme isEqualToString:@"file"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    DDLogInfo(@"%@", navigationResponse.response.class);
    NSURLResponse *r = (NSURLResponse *) navigationResponse.response;
    if ([r isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) r;
        NSInteger code = response.statusCode;
        NSString *contentType = [response.allHeaderFields objectForKey:@"Content-Type"];
        DDLogInfo(@"%ld Content-Length: %lld Content-Type: %@", code, response.expectedContentLength, contentType);
        DDLogInfo(@"%@; charset=%@", response.MIMEType, response.textEncodingName);
        if (contentType) {
            contentType = [contentType lowercaseStringWithLocale:[NSLocale currentLocale]];
            MediaType *media = [MediaType get:contentType];
            DDLogInfo(@"media:%@", media);
            if (!media) {
                decisionHandler(WKNavigationResponsePolicyAllow);
            } else if([@"text" isEqualToString:media.type] && [@"html" isEqualToString:media.subtype]) {
                decisionHandler(WKNavigationResponsePolicyAllow);
            } else {
                decisionHandler(WKNavigationResponsePolicyCancel);
                FileLookController *c = [[FileLookController alloc] init:response.URL];
                [self.navigationController pushViewController:c animated:YES];
            }
            return;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)showError:(NSError *)error {
    if (_textView.hidden == NO) {
        return;
    }
    _textView.hidden = NO;
    _webView.hidden = YES;
    if (error.userInfo) {
        NSString *description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        NSString *suggestion = [error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey];
        if (suggestion) {
            _textView.text = [NSString stringWithFormat:@"%@\n%@", description,suggestion ];
        } else {
            _textView.text = [NSString stringWithFormat:@"%@", description];
        }
        CGFloat l = 10;
        CGFloat w = self.view.frame.size.width - 10 - 10;
        CGFloat h = self.view.frame.size.height;
        CGFloat t = [[UIScreen mainScreen] bounds].size.height - h;
        CGRect rect = [_textView.text boundingRectWithSize:CGSizeMake(w, h)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{NSFontAttributeName:_textView.font}
                                                   context:nil];
        CGFloat textHeight = rect.size.height;
        _textView.frame = CGRectMake(l, (h - textHeight) / 2 - t, w, textHeight);
    }
}

- (void)dealloc {
    DDLogInfo(@"");
    [_webView removeObserver:self forKeyPath:@"title"];
}

@end
