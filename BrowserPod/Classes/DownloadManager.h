#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FileStatus) {
    FileDownFail,
    FileOpenFail,
    FileEmpty,
    FileNoSupport
};

NS_ASSUME_NONNULL_BEGIN

@protocol DownloadDelegate

- (void)downloadProcess:(NSProgress *)progress;

- (void)downloadSuccess:(NSString *)filePath;

- (void)downloadError:(NSString *)error withFailStatus:(FileStatus)fileStatus;

@end

@interface DownloadManager : NSObject

@property (nonatomic, weak, nullable) id <DownloadDelegate> delegate;

- (void)start:(NSURL *)url destination:(NSString *)dir filename:(NSString *)filename;

- (void)cancel;

- (BOOL)canPreview:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
