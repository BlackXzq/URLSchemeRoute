//
//  BaseViewController.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/27.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<BKRouteProtocol>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 处理route
 */

+ (BOOL)canRouteUrl:(NSString *)url {
    return true;
}

- (RouteCallback *)willRouteUri:(NSString *)uri info:(id)info {
    RouteCallback *callback = [RouteCallback new];
    callback.operation = RouteCallbackOperationPush;
    return callback;
}

@end
