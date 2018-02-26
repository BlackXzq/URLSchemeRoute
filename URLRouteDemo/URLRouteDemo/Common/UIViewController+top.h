//
//  UIViewController+top.h
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (top)

+ (UIViewController *)topBaseViewController;
+ (UIViewController *)rootViewControler;

- (UIViewController *)navigationPushViewController:(UIViewController *)controller animated:(BOOL)animated;

@end
