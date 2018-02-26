//
//  BKRoutes.m
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import "BKRoutes.h"

static NSString *patternPrefix = @"bkroute://urlroute.black.com";

#pragma mark- RouteCallback
@implementation RouteCallback

- (instancetype)init {
    self = [super init];
    if (self) {
        _tabIndex = -1;
    }
    return self;
}

+ (instancetype)routeCallBackWithOperation:(RouteCallbackOperation)operationType {
    RouteCallback *callback = [[self alloc] init];
    callback.operation = operationType;
    return callback;
}

+ (instancetype)noneCallback {
    return [self routeCallBackWithOperation:RouteCallbackOperationNone];
}

+ (instancetype)utilCallback {
    return [self routeCallBackWithOperation:RouteCallbackOperationUtil];
}

+ (instancetype)pushCallback {
    return [self routeCallBackWithOperation:RouteCallbackOperationPush];
}

+ (instancetype)presentCallback {
    return [self routeCallBackWithOperation:RouteCallbackOperationPresent];
}

@end

#pragma mark- Route
@implementation Route

- (instancetype)initWithPattern:(NSString *)pattern className:(NSString *)className {
    self = [super init];
    if (self) {
        _pattern = pattern;
        _className = className;
    }
    return self;
}

- (instancetype)initWithPattern:(NSString *)pattern block:(void (^)(NSString *, NSDictionary *))block {
    self = [super init];
    if (self) {
        _pattern = pattern;
        _block = block;
    }
    return self;
}

+ (instancetype)routeWithPattern:(NSString *)pattern className:(NSString *)className {
    return [[self alloc] initWithPattern:pattern className:className];
}

+ (instancetype)routeWithPattern:(NSString *)pattern block:(void (^)(NSString *, NSDictionary *))block {
    return [[self alloc] initWithPattern:pattern block:block];
}

- (NSString *)description {
    if (self.className) {
        return [NSString stringWithFormat:@"(Pattern: %@, className:%@)", self.pattern, self.className];
    } else {
        return [NSString stringWithFormat:@"(Pattern: %@, [block]", self.pattern];
    }
}

@end

#pragma mark- BKRoutes

@interface BKRoutes()
@property (strong, nonatomic) NSMutableArray *routes;
@end

@implementation BKRoutes

+ (instancetype)defaultRoutes {
    static dispatch_once_t onceToken;
    static id defaultRoutes;
    
    dispatch_once(&onceToken, ^{
        defaultRoutes = [[BKRoutes alloc] init];
    });
    
    return defaultRoutes;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _routes = [NSMutableArray array];
    }
    return self;
}

/**
 是否匹配模式， 现在模式匹配判断条件是，前缀相同，之后的一个字符是/; 例如：/home/bin 匹配模式/home
 
 */
- (BOOL)matchPatten:(NSString *)pattern withUri:(NSString *)uri {
    if (![uri hasPrefix:pattern]) {
        return NO;
    }
    
    NSString *sub = [uri substringFromIndex:pattern.length];
    if ([sub length] != 0) {
        return [sub hasPrefix:@"/"];
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - Manage Routes

- (void)addRoute:(Route *)route {
    NSAssert([route.pattern hasPrefix:@"/"], @"Route's pattern should start with /");
    
    if ([route.className length] != 0) {
        Class classType = NSClassFromString(route.className);
        NSAssert(classType != nil, @"[BKRoutes] Can't find %@ class", route.className);
        NSAssert([classType conformsToProtocol:@protocol(HJRouteProtocol)], @"[BKRoutes] %@ not conform protocol: HJRouteProtocol", route.className);
    } else {
        NSAssert(route.block != NULL, @"[BKRoutes] Block is invalid");
    }
    
    NSLog(@"[BKRoutes] Register route %@ success", route.pattern);
    [self.routes addObject:route];
}

- (void)removeRoute:(Route *)route {
    [self.routes removeObject:route];
}

- (void)removeRouteWithPattern:(NSString *)pattern {
    __block Route *tempRoute = nil;
    [self.routes enumerateObjectsUsingBlock:^(Route *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.pattern isEqualToString:pattern]) {
            tempRoute = obj;
            *stop = true;
        }
    }];
    
    if (tempRoute != nil) {
        [self.routes removeObject:tempRoute];
    }
}

- (void)clearRoutes {
    [self.routes removeAllObjects];
}

- (void)modifyRouteWithPattern:(NSString *)pattern newClassName:(NSString *)newClassName {
    for (Route *route in self.routes) {
        if ([route.pattern isEqualToString:pattern]) {
            route.className = newClassName;
            break;
        }
    }
}

#pragma mark - Deal with routes

- (BOOL)_routeUri:(NSString *)uri withInfo:(NSDictionary *)info isPresent:(BOOL)present {
    
    Route *target = nil;
    for (Route *route in self.routes) {
        if ([self matchPatten:route.pattern withUri:uri]) {
            target = route;
            break;
        }
    }
    
    if (!target) {
        NSLog(@"[BKRoute] Warn: Can not find target route: %@", uri);
        return NO;
    }
    
    //Deal with block
    if (target.block) {
        target.block(uri, info);
        return YES;
    }
    
    //Get View Controller Instance
    
    Class classType = NSClassFromString(target.className);
    UIViewController<HJRouteProtocol> *vc = [self getViewController:classType];
    if (!vc) {
        NSLog(@"[BKRoute] Error: Instance class failed");
        return NO;
    }
    
    // Deal with canRouteUrl callback
    if ([classType resolveClassMethod:@selector(canRouteUri:)]) {
        if(![classType canRouteUri:uri]) {
            NSLog(@"[BKRoute] Can not open the route");
            return NO;
        }
    }
    
    UIViewController *topNav = [UIViewController topBaseViewController];
    if (topNav == nil) {
        topNav = [UIWindow visibleViewController];
    }
    // ViewController没有实现willRouteUri： 则默认处理
    if (![vc respondsToSelector:@selector(willRouteUri:info:)]) {
        if (present) {
            [topNav presentViewController:vc animated:YES completion:nil];
        } else {
            [topNav navigationPushViewController:vc animated:YES];
        }
        return YES;
    }
    
    UIViewController *dstVc = vc;
    RouteCallback *callback = [vc willRouteUri:uri info:info];
    if (!callback) {
        NSLog(@"[BKRoute] Warn: You may havn't implement the function willRouteUrl");
        return NO;
    }
    
    //switch tabbar index
    if (callback.tabIndex != -1) {
        UITabBarController *tabVc = (UITabBarController *)[UIViewController rootViewControler];
        [tabVc setSelectedIndex:callback.tabIndex];
        topNav = [UIViewController topBaseViewController];
    }
    
    if (callback.needPop) {
        [self popViewControllerByClassType:classType];
    }
    
    if (callback.popToRoot) {
        [[UIViewController topBaseViewController].navigationController popToRootViewControllerAnimated:NO];
        topNav = [UIViewController topBaseViewController];
    }
    
    //show Viewcontroller
    switch (callback.operation) {
        case RouteCallbackOperationPush:
            [topNav navigationPushViewController:dstVc animated:YES];
            break;
        case RouteCallbackOperationUtil:
            if (IS_IPAD) {
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dstVc];
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
                [topNav presentViewController:nav animated:YES completion:nil];
            } else {
                [topNav navigationPushViewController:dstVc animated:YES];
            }
            break;
        case RouteCallbackOperationPresent:
            [topNav presentViewController:dstVc animated:YES completion:nil];
            break;
        default:
            return NO;
            break;
    }
    
    return YES;
}

- (BOOL)routeUrl:(NSString *)url {
    return [self routeUrl:url isPresent:NO];
}

- (BOOL)routeUrl:(NSString *)url isPresent:(BOOL)present {
    NSLog(@"[BKRoute] Dealing with scheme: %@", url);
    
    // Parse params
    if (![url hasPrefix:patternPrefix]) {
        NSLog(@"[BKRoute] Error: Invalid scheme");
        return NO;
    }
    
    NSString *uri = nil;
    NSDictionary *info = [self parseUrl:url path:&uri];
    
    // Application open self
    if (uri == nil || [uri isEqualToString:@"/"]) {
        return NO;
    }
    
    return [self _routeUri:uri withInfo:info isPresent:present];
}

+ (BOOL)routeUri:(NSString *)uri withInfo:(NSDictionary *)info {
    return [self routeUri:uri withInfo:info isPresent:NO];
}

+ (BOOL)routeUri:(NSString *)uri withInfo:(NSDictionary *)info isPresent:(BOOL)present{
    return [[self defaultRoutes] _routeUri:uri withInfo:info isPresent:present];
}

- (void)routeViewController:(UIViewController *)vc inParent:(UIViewController *)parent isPresent:(BOOL)present {
    if (!parent) {
        parent = [UIViewController topBaseViewController];
    }
    
    // TODO: Dismiss current present ViewController
    
    if (present) {
        [parent presentViewController:vc animated:YES completion:nil];
    } else {
        [parent.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Parse route

- (NSDictionary *)parseUrl:(NSString *)url path:(NSString **)path {
    NSURL *_url = [NSURL URLWithString:url];
    if (_url == nil || _url.path == nil) {
        NSLog(@"[Route] Error: Invalid url");
        return nil;
    }
    
    if (path != nil) {
        *path = _url.path;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_url.query) {
        NSArray *composents = [_url.query componentsSeparatedByString:@"&"];
        composents = [self filteEmptyStringArray:composents];
        
        for (NSString *composent in composents) {
            NSArray *pair = [composent componentsSeparatedByString:@"="];
            if ([pair count] ==2 && [pair[1] length] > 0) {
                [dict setValue:pair[1] forKey:pair[0]];
            }
        }
    }
    
    if ([dict count] > 0) {
        return [NSDictionary dictionaryWithDictionary:dict];
    } else {
        return nil;
    }
}

#pragma mark - Util stub

- (NSArray<NSString *> *)filteEmptyStringArray:(NSArray<NSString *> *)arr {
    return [arr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject length] > 0;
    }]];
}

- (void)popViewControllerByClassType:(Class)classType {
    UIViewController *topNav = [UIViewController topBaseViewController];
    if (topNav.navigationController.modalPresentationStyle == UIModalPresentationFormSheet) {
        [topNav.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        for (UIViewController *vc in topNav.navigationController.viewControllers) {
            if ([vc isKindOfClass:classType]) {
                [topNav.navigationController popToViewController:vc animated:YES];
                [topNav.navigationController popViewControllerAnimated:YES];
                
                break;
            }
        }
    }
}

/**
 *  Creat a View Controller of this type
 *
 *  @param classType ViewController's type
 *
 *  @return viewController
 */
- (UIViewController<HJRouteProtocol> *)getViewController:(Class)classType {
    // TODO: May be change
//    if ([classType resolveClassMethod:@selector(sharedInstance)]) {
//        return [classType sharedInstance];
//    } else {
        return [[classType alloc] init];
//    }
}

#pragma mark - Debug

- (NSInteger)count {
    return [self.routes count];
}

- (void)printAllRoutes {
    if ([self.routes count] == 0) {
        NSLog(@"[BKRoute] No route");
    } else {
        for (Route *route in self.routes) {
            NSLog(@"[BKRoute] %@", route);
        }
    }
}

@end

@implementation BKRoutes (UrlExtractor)
/// 提取合法的url
+ (NSURL *)getUrlFromDict:(NSDictionary *)info inKey:(NSString *)key {
    if (!info || [info count] == 0) {
        return nil;
    }
    
    NSString *strUrl = [[info valueForKey:@"url"] urlDecode];
    NSURL *dstUrl = [NSURL URLWithString:strUrl];
    
    if (!strUrl || !dstUrl || !dstUrl.host || !dstUrl.path) {
        NSLog(@"[BKRoute] Invalid url: %@", strUrl);
        return nil;
    }
    
    return dstUrl;
}

@end
