//
//  BKRouteUri.h
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKRouteUri : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *source;

+ (instancetype)uriWithName:(NSString *)name;

@end
