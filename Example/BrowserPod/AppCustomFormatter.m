//
//  AppCustomFormatter.m
//  IPOFLOW
//
//  Created by y on 2019/11/22.
//  Copyright © 2019 pfshao. All rights reserved.
//

#import "AppCustomFormatter.h"

@implementation AppCustomFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage.flag) {
        case DDLogFlagError    : logLevel = @"E"; break;
        case DDLogFlagWarning  : logLevel = @"W"; break;
        case DDLogFlagInfo     : logLevel = @"I"; break;
        case DDLogFlagDebug    : logLevel = @"D"; break;
        default                : logLevel = @"V"; break;
    }
    return [NSString stringWithFormat:@"[%@][%@]%@[%ld] %@", logLevel, logMessage.queueLabel,
            logMessage.function, logMessage.line, logMessage.message];
}

@end
