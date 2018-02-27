//
//  SecondViewController.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/27.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (nonatomic, strong) NSString *currentTitle;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.currentTitle;
    self.view.backgroundColor = [UIColor yellowColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (RouteCallback *)willRouteUri:(NSString *)uri info:(id)info {
    RouteCallback *callback = [RouteCallback new];
    NSString *useName = info[@"name"];
    NSString *phone = info[@"phone"];
    self.currentTitle = [NSString stringWithFormat:@"%@ + %@", useName, phone];
    NSLog(@"useName: %@", useName);
    NSLog(@"phone: %@", phone);
    callback.operation = RouteCallbackOperationPush;
    return callback;
}

@end
