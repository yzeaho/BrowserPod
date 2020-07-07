#import "MediaType.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface MediaType ()


@end

@implementation MediaType

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

- (instancetype)init:(NSString *)string type:(NSString *)type subtype:(NSString *)subtype charset:(NSString *)charset {
    self = [super init];
    if (self) {
        _type = type;
        _subtype = subtype;
        _charset = charset;
    }
    return self;
}

+ (MediaType *)get:(NSString *)string {
    DDLogVerbose(@"%@", string);
    NSString *token = @"([a-zA-Z0-9-!#$%&'*+.^_`{|}~]+)";
    NSString *pattern = [NSString stringWithFormat:@"%@/%@", token, token];
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    if (!regular) {
        return nil;
    }
    NSArray<NSTextCheckingResult *> *results = [regular matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    DDLogVerbose(@"count:%ld", results.count);
    if (results.count < 0) {
        return nil;
    }
    NSTextCheckingResult *result = [results objectAtIndex:0];
    DDLogVerbose(@"numberOfRanges:%ld", result.numberOfRanges);
    if (result.numberOfRanges < 3) {
        return nil;
    }
    NSString *type = [MediaType substring:string WithRange:[result rangeAtIndex:1]];
    NSString *subtype = [MediaType substring:string WithRange:[result rangeAtIndex:2]];
    DDLogVerbose(@"type:%@", type);
    DDLogVerbose(@"subtype:%@", subtype);
    
    NSString *charset = nil;
    NSString *quoted = @"\"([^\"]*)\"";
    NSString *parameter = [NSString stringWithFormat:@";\\s*(?:%@=(?:%@|%@))?", token, token, quoted];
    regular = [NSRegularExpression regularExpressionWithPattern:parameter options:NSRegularExpressionCaseInsensitive error:nil];
    results = [regular matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (results) {
        DDLogVerbose(@"count:%ld", results.count);
        if (results.count > 0) {
            NSTextCheckingResult *result = [results objectAtIndex:0];
            DDLogVerbose(@"numberOfRanges:%ld", result.numberOfRanges);
            if (result.numberOfRanges > 3) {
                NSString *name = [MediaType substring:string WithRange:[result rangeAtIndex:1]];
                DDLogVerbose(@"name:%@", name);
                charset = [MediaType substring:string WithRange:[result rangeAtIndex:2]];
                DDLogVerbose(@"charset:%@", charset);
            }
        }
    }
    return [[MediaType alloc] init:string type:type subtype:subtype charset:charset];
}

+ (NSString *)substring:(NSString *)string WithRange:(NSRange)range {
    if (range.location <= [string length]) {
        return [string substringWithRange:range];
    } else {
        return nil;
    }
}

- (NSString *)description {
    if (_charset) {
        return [NSString stringWithFormat:@"%@/%@; charset=%@", _type, _subtype, _charset];
    } else {
        return [NSString stringWithFormat:@"%@/%@", _type, _subtype];
    }
}

@end
