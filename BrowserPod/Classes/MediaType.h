#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An <a href="http://tools.ietf.org/html/rfc2045">RFC 2045</a> Media Type, appropriate to describe
 * the content type of an HTTP request or response body.
*/
@interface MediaType : NSObject

/**
 * the encoded media type, like "text/plain; charset=utf-8", appropriate for use in a Content-Type header.
 */
@property (nonatomic, readonly, copy) NSString *mediaType;

/**
 * the high-level media type, such as "text", "image", "audio", "video", or "application".
 */
@property (nonatomic, readonly, copy) NSString *type;

/**
 * a specific media subtype, such as "plain" or "png", "mpeg", "mp4" or "xml".
 */
@property (nonatomic, readonly, copy) NSString *subtype;

/**
 * the charset of this media type, or null if this media type doesn't specify a charset.
 */
@property (nonatomic, readonly, copy) NSString *charset;

/**
 * Returns a media type string.
 */
+ (MediaType *)get:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
