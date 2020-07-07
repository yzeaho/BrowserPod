#import "ErrorView.h"

@implementation ErrorView

- (instancetype)init {
    self = [super init];
    if (self) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.masksToBounds = YES;
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconView];
        
        _textView = [[UILabel alloc] init];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.font = [UIFont systemFontOfSize:18];
        [self addSubview:_textView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setup:(CGRect)frame {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"Frameworks/BrowserPod.framework/BrowserPod" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    UIImage *image = [UIImage imageNamed:@"ic_download" inBundle:bundle compatibleWithTraitCollection:nil];
    [self setup:frame icon:image text:@""];
}

- (void)setup:(CGRect)frame icon:(UIImage *)icon text:(NSString *)text {
    _iconView.image = icon;
    _textView.text = text;
    self.frame = frame;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!_iconView) {
        return;
    }
    CGFloat padding = 10;
    CGFloat centerY = frame.size.height / 5 * 2;
    CGFloat x = (frame.size.width - _iconView.image.size.width) / 2;
    CGFloat y = centerY - _iconView.image.size.height - padding;
    _iconView.frame = CGRectMake(x, y, _iconView.image.size.width, _iconView.image.size.height);
    
    CGRect rect = [_textView.text boundingRectWithSize:CGSizeMake(frame.size.width, frame.size.height)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:_textView.font}
                                               context:nil];
    y = centerY + padding;
    _textView.frame = CGRectMake(padding, y, frame.size.width - padding * 2, rect.size.height);
}

@end
