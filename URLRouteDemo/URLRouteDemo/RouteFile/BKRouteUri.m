//
//  BKRouteUri.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "BKRouteUri.h"

@implementation BKRouteUri

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

+ (instancetype)uriWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

@end
