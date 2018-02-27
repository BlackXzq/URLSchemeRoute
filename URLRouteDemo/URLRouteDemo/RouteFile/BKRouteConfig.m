//
//  BKRouteConfig.m
//  URLRouteDemo
//
//  Created by xu on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "BKRouteConfig.h"
#import "BKRoutes.h"

@implementation BKRouteConfig
+ (void)config {
    BKRoutes *routes = [BKRoutes defaultRoutes];
    [routes addRoute:[Route routeWithPattern:@"/first" className:@"FirstViewController"]];
    [routes addRoute:[Route routeWithPattern:@"/second" className:@"SecondViewController"]];
    [routes addRoute:[Route routeWithPattern:@"/log" block:^(NSString *path, NSDictionary *info) {
        NSLog(@"XxXXXXXXXXXXXXX");
    }]];
}
@end
