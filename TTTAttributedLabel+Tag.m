//
//  TTTAttributedLabel+Tag.m
//  DoGood
//
//  Created by Michael on 2013-10-19.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "TTTAttributedLabel+Tag.h"

static inline  NSRegularExpression * HashRegularExpression()
{
    static NSRegularExpression *_HashRegularExpression = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _HashRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(?:^|\\s|[\\p{Punct}&&[^/]])(#[\\p{L}0-9-_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return _HashRegularExpression;
}

@implementation TTTAttributedLabel (Tag)

- (void)hashIfy:(NSAttributedString *)string inLabel:(TTTAttributedLabel *)label {
    NSRange stringRange = NSMakeRange(0, [string length]);
    NSRegularExpression *regexp = HashRegularExpression();
    [regexp enumerateMatchesInString:[string string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *noHashes = [[[string string] substringWithRange:result.range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
        NSString *noSpacesAndNoHashes = [noHashes stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *urlString = [NSString stringWithFormat:@"dogood://goods/tagged/%@", noSpacesAndNoHashes];
        NSURL *url = [NSURL URLWithString:urlString];
        // DebugLog(@"URL string %@ %@ %@", urlString, noSpacesAndNoHashes, noHashes, [url absoluteString]);
        [label addLinkToURL:url withRange:result.range];
    }];
}

@end
