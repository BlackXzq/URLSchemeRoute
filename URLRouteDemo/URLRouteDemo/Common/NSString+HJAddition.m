//
//  NSString+HJAddition.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "NSString+HJAddition.h"

@implementation NSString (HJAddition)

- (NSString*)urlEncode {
    return [self enurlCode];
}

- (NSString *)urlDecode {
    return [self enurlDecode];
}

- (NSString*)enurlCode{
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

- (NSString *)enurlDecode{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}

@end
