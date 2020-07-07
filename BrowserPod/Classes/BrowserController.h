#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "AppNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface BrowserController : UIViewController

@property (nonatomic, strong) AppNavigationBar *appNavigationBar;
@property (nonatomic, strong) NSURL *htmlUrl;

+ (WKProcessPool*)sharedProcessPool;

@end

NS_ASSUME_NONNULL_END
