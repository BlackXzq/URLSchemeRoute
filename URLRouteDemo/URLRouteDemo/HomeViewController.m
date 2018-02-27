//
//  HomeViewController.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) UIWebView *useWebView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.view.backgroundColor = [UIColor redColor];
    
    _useWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _useWebView.scrollView.bounces = false;
    [self.view addSubview:_useWebView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"UserInfo" ofType:@"html"];
    NSURL *url = [[NSURL alloc] initWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_useWebView loadRequest:request];
    
    UIButton *backBtn = [UIButton new];
    backBtn.frame = CGRectMake(100, 300, 100, 60);
    [backBtn setBackgroundColor:[UIColor lightGrayColor]];
    [backBtn setTitle:@"First" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)backBtnClicked:(UIButton *)sender {
    [[BKRoutes defaultRoutes] routeUrl:@"bkroute://urlroute.black.com/first"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
