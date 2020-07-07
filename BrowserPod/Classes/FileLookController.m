#import "FileLookController.h"
#import <CommonCrypto/CommonCrypto.h>
#import <QuickLook/QuickLook.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AppNavigationBar.h>
#import "DownloadManager.h"
#import "DownloadView.h"
#import "ErrorView.h"

@interface FileLookController ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate, AppNavigationBarDelegate, DownloadDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *ext;
@property (nonatomic, strong) NSString *localFilePath;
@property (nonatomic, strong) DownloadView *downloadView;
@property (nonatomic, strong) DownloadManager *downloadManager;
@property (nonatomic, strong) ErrorView *errorView;

@end

@implementation FileLookController

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

- (instancetype)init:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _fileName = url.lastPathComponent;
        _ext = [url pathExtension];
    }
    return self;
}

+ (NSError *)clearCache {
    NSError *error;
    NSString *dir = [FileLookController downloadDir];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:&error];
    return error;
}

+ (NSString *)downloadDir {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadDir = [documentDir stringByAppendingPathComponent:@"browser/download"];
    return downloadDir;
}

+ (NSString*)md5:(NSString*)sourceString {
    if (!sourceString){
        return nil;
    }
    const char* cString = sourceString.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, (CC_LONG) strlen(cString), result);
    NSMutableString *resultString = [[NSMutableString alloc]init];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02x",result[i]];
    }
    return resultString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DDLogInfo(@"");
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _appNavigationBar = [[AppNavigationBar alloc] init:self.navigationController.navigationBar title:_fileName];
    _appNavigationBar.delegate = self;
    [self.view addSubview:_appNavigationBar];
    
    _errorView = [[ErrorView alloc] init];
    [_errorView setup:CGRectMake(0, _appNavigationBar.frame.size.height,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height - _appNavigationBar.frame.size.height)];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(download)];
    [_errorView addGestureRecognizer:gesture];
    _errorView.userInteractionEnabled = NO;
    _errorView.hidden = YES;
    [self.view addSubview:_errorView];
    
    _downloadManager = [DownloadManager new];
    _downloadManager.delegate = self;
    
    NSString *dir = [FileLookController downloadDir];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [FileLookController md5:_url.absoluteString], _ext];
    NSString *localFilePath = [dir stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        [self openFile:localFilePath];
    } else {
        [self download];
    }
}

- (void)navigationBarGoToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)download {
    if (_downloadView.superview == nil) {
        CGFloat y = _appNavigationBar.frame.origin.y + _appNavigationBar.frame.size.height;
        CGFloat h = self.view.frame.size.height - y;
        CGRect rect = CGRectMake(0, y, self.view.frame.size.width, h);
        _downloadView = [[DownloadView alloc] initWithFrame:rect];
        [self.view addSubview:_downloadView];
    }
    [self startDownload];
}

- (void)startDownload {
    NSString *dir = [FileLookController downloadDir];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [FileLookController md5:_url.absoluteString], _ext];
    [_downloadManager start:_url destination:dir filename:filename];
}

- (void)downloadProcess:(NSProgress *)progress {
    CGFloat p = progress.completedUnitCount * 100 / progress.totalUnitCount;
    [_downloadView setProgress:p];
}

- (void)downloadSuccess:(NSString *)filePath {
    DDLogDebug(@"%@", filePath);
    [_downloadView removeFromSuperview];
    [self openFile:filePath];
}

- (void)downloadError:(NSString *)error withFailStatus:(FileStatus)fileStatus {
    DDLogDebug(@"%@", error);
    switch (fileStatus) {
        case FileDownFail:
            _errorView.userInteractionEnabled = YES;
            break;
        default:
            _errorView.userInteractionEnabled = NO;
            break;
    }
    [_downloadView removeFromSuperview];
    _errorView.hidden = NO;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"Frameworks/BrowserPod.framework/BrowserPod" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    _errorView.textView.text = NSLocalizedStringFromTableInBundle(error, @"BrowserPod", bundle, nil);
    _errorView.frame = CGRectMake(0, _appNavigationBar.frame.origin.y + _appNavigationBar.frame.size.height,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height - _appNavigationBar.frame.size.height);
}

- (void)openFile:(NSString *)path {
    DDLogDebug(@"%@", path);
    _localFilePath = path;
    if (![_downloadManager canPreview:[NSURL fileURLWithPath:_localFilePath]]) {
        [self downloadError:@"file.error.nosupport" withFailStatus:FileNoSupport];
        return;
    }
    if (![QLPreviewController canPreviewItem:[NSURL fileURLWithPath:_localFilePath]]) {
        [self downloadError:@"file.error.nosupport" withFailStatus:FileNoSupport];
        return;
    }
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    //preview.delegate = self;
    CGFloat y = _appNavigationBar.frame.origin.y + _appNavigationBar.frame.size.height;
    CGFloat h = self.view.frame.size.height - y;
    preview.view.frame= CGRectMake(0, y, self.view.frame.size.width, h);
    [self addChildViewController:preview];
    [self.view addSubview:preview.view];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:_localFilePath];
}

- (void)dealloc {
    DDLogDebug(@"");
    [_downloadManager cancel];
}

@end
