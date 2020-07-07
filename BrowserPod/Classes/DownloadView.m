#import "DownloadView.h"

@interface DownloadView ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation DownloadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat progressHeight = 25;
        CGFloat padding = 10;
        CGFloat centerY = frame.size.height / 5 * 2;
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *path = [mainBundle pathForResource:@"Frameworks/BrowserPod.framework/BrowserPod" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        UIImage *image = [UIImage imageNamed:@"ic_download" inBundle:bundle compatibleWithTraitCollection:nil];
        CGFloat x = (frame.size.width - image.size.width) / 2;
        CGFloat y = centerY - padding - image.size.height;
        CGRect rect = CGRectMake(x, y, image.size.width, image.size.height);
        UIImageView *icon = [[UIImageView alloc] initWithFrame:rect];
        icon.image = image;
        [self addSubview:icon];
        
        _progressView = [[UIProgressView alloc] init];
        _progressView.frame = CGRectMake(frame.size.width * 0.2,
                                         icon.frame.origin.y  + icon.frame.size.height + padding,
                                         frame.size.width * 0.6, progressHeight);
        _progressView.transform = CGAffineTransformMakeScale(1.0, 2.0);
        [self addSubview:_progressView];
        
        x = padding;
        y = _progressView.frame.origin.y + _progressView.frame.size.height + padding;
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _progressLabel.text = @"0%";
        _progressLabel.font = [UIFont systemFontOfSize:18];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        rect = [_progressLabel.text boundingRectWithSize:CGSizeMake(frame.size.width, frame.size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName:_progressLabel.font}
                                                 context:nil];
        _progressLabel.frame = CGRectMake(x, y, frame.size.width - padding * 2, rect.size.height);
        [self addSubview:_progressLabel];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    [_progressView setProgress:progress / 100 animated:YES];
    _progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress)];
}

@end
