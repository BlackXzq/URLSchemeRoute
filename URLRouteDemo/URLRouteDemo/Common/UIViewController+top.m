//
//  UIViewController+top.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "UIViewController+top.h"

@implementation UIViewController (top)

+ (UIViewController *)topBaseViewController {
    UIViewController *rootCtl = [self rootViewControler];
    return [self baseViewControllerForController:rootCtl];
}

+ (UIViewController *)baseViewControllerForController:(UIViewController *)controller {
    if ([controller isKindOfClass:[BaseViewController class]]) {
        return controller;
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self baseViewControllerInNavigation:(UINavigationController *)controller];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self baseViewControllerInTab:(UITabBarController *)controller];
    }
    
    return nil;
}

+ (UIViewController *)baseViewControllerInTab:(UITabBarController *)tabBarController {
    if (!tabBarController) {
        return nil;
    }
    
    UIViewController *currentController = nil;
    if (tabBarController.selectedIndex < [tabBarController.childViewControllers count]) {
        currentController = [tabBarController.childViewControllers objectAtIndex:tabBarController.selectedIndex];
    }
    
    return [self baseViewControllerForController:currentController];
}

+ (UIViewController *)baseViewControllerInNavigation:(UINavigationController *)navigationController {
    if (!navigationController) {
        return nil;
    }
    
    UIViewController *topController = navigationController.topViewController;
    return [self baseViewControllerForController:topController];
}

+ (UIViewController *)rootViewControler
{
    UIViewController* controller = nil;
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (!window || window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    if (window) {
        NSArray* subViews = [window subviews];
        if (subViews && [subViews count] > 0) {
            UIView* rootView = [[window subviews] objectAtIndex:0];
            id nextResponder = [rootView nextResponder];
            if ([nextResponder isKindOfClass:[UIWindow class]]) {
                controller = ((UIWindow*)nextResponder).rootViewController;
            } else if ([nextResponder isKindOfClass:[UIViewController class]]) {
                controller = nextResponder;
            }
        }
        
        if (!controller && [window respondsToSelector:@selector(rootViewController)]) {
            controller = window.rootViewController;
        }
    }
    
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    
    return controller;
}


- (UIViewController *)navigationPushViewController:(UIViewController *)controller animated:(BOOL)animated
{
    if (!self.navigationController)
    {
        return controller;
    }
    
    [controller setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:controller animated:animated];
    return controller;
}

@end
