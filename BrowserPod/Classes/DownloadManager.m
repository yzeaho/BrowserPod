#import "DownloadManager.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DownloadManager ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (readonly, copy) NSMutableSet *supportSet;

@end

@implementation DownloadManager

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setSupportFileType];
    }
    return self;
}

- (void)setSupportFileType {
    _supportSet = [NSMutableSet set];
    // 图片
    [_supportSet addObject:@"jpg"];
    [_supportSet addObject:@"jpeg"];
    [_supportSet addObject:@"jpe"];
    [_supportSet addObject:@"png"];
    [_supportSet addObject:@"bmp"];
    [_supportSet addObject:@"gif"];
    // 其他文本
    [_supportSet addObject:@"txt"];
    [_supportSet addObject:@"pdf"];
    // office
    [_supportSet addObject:@"doc"];
    [_supportSet addObject:@"docx"];
    [_supportSet addObject:@"dot"];
    [_supportSet addObject:@"dotx"];
    [_supportSet addObject:@"xls"];
    [_supportSet addObject:@"xlsx"];
    [_supportSet addObject:@"xlt"];
    [_supportSet addObject:@"xltx"];
    [_supportSet addObject:@"ppt"];
    [_supportSet addObject:@"pot"];
    [_supportSet addObject:@"pps"];
    [_supportSet addObject:@"pptx"];
    [_supportSet addObject:@"potx"];
    [_supportSet addObject:@"ppsx"];
}

- (void)start:(NSURL *)url destination:(NSString *)dir filename:(NSString *)filename {
    @weakify(self);
    DDLogDebug(@"%@", url);
    DDLogDebug(@"%@", dir);
    DDLogDebug(@"%@", filename);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _downloadTask = [[AFHTTPSessionManager manager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        @strongify(self);
        if (!self) {
            return;
        }
        [self notifyDownloadProgress:downloadProgress];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *tmp = [NSString stringWithFormat:@"%@.bak", filename];
        NSString *fullPath = [dir stringByAppendingPathComponent:tmp];
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        @strongify(self);
        if (!self) {
            return;
        }
        if (error) {
            [self.delegate downloadError:@"file.error.download" withFailStatus:FileDownFail];
            DDLogError(@"file is dowmload fail, error message is %@",error.description);
            return;
        }
        NSHTTPURLResponse *r = (NSHTTPURLResponse *) response;
        if (![r isKindOfClass:[NSHTTPURLResponse class]]) {
            [self.delegate downloadError:@"file.error.nosupport" withFailStatus:FileNoSupport];
            return;
        }
        NSInteger code = r.statusCode;
        NSURL *url = response.URL;
        DDLogInfo(@"%@", r.allHeaderFields);
        NSString *contentType = [r.allHeaderFields objectForKey:@"Content-Type"];
        DDLogInfo(@"code:%ld contentType:%@", code, contentType);
        if (code >= 200 && code < 300) {
            NSString *localFilePath = [dir stringByAppendingPathComponent:filename];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:filePath.path toPath:localFilePath error:&error];
            DDLogWarn(@"moveItemAtPath error:%@", error);
            if (error) {
                [self.delegate downloadError:@"file.error.system" withFailStatus:FileDownFail];
                return;
            }
            NSString *ext = [[url pathExtension] lowercaseStringWithLocale:[NSLocale currentLocale]];
            DDLogInfo(@"ext:%@", ext);
            if (![self.supportSet containsObject:ext]) {
                [self.delegate downloadError:@"file.error.nosupport" withFailStatus:FileNoSupport];
                return;
            }
            if ([contentType containsString:@"html"]) {
                [self.delegate downloadError:@"file.error.nosupport" withFailStatus:FileNoSupport];
                return;
            }
            if (response.expectedContentLength == 0) {
                [self.delegate downloadError:@"file.error.empty" withFailStatus:FileEmpty];
                return;
            }
            [self.delegate downloadSuccess:localFilePath];
        } else {
            [self.delegate downloadError:@"file.error.download" withFailStatus:FileDownFail];
        }
    }];
    [_downloadTask resume];
}

- (void)notifyDownloadProgress:(NSProgress *)progress {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.delegate downloadProcess:progress];
    });
}

- (void)cancel {
    DDLogDebug(@"");
    [_downloadTask cancel];
    _downloadTask = nil;
}

- (BOOL)canPreview:(NSURL *)url {
    NSString *ext = [[url pathExtension] lowercaseStringWithLocale:[NSLocale currentLocale]];
    return [self.supportSet containsObject:ext];
}

@end
