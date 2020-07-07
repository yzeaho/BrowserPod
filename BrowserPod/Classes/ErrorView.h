#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorView : UIView

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textView;

- (void)setup:(CGRect)frame;

- (void)setup:(CGRect)frame icon:(UIImage *)icon text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
