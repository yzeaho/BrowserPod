#import <UIKit/UIKit.h>
#import "AppNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileLookController : UIViewController

@property (nonatomic, strong) AppNavigationBar *appNavigationBar;

- (instancetype)init:(NSURL *)url;

+ (NSError *)clearCache;

@end

NS_ASSUME_NONNULL_END
