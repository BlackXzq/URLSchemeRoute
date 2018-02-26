//
//  BKRoutes.h
//  URLRouteDemo
//
//  Created by Black on 2018/2/26.
//  Copyright © 2018年 Black. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 术语约定：
 *      url: 完整的scheme地址
 *      uri: 资源地址，或注册的pattern, 只是url的一部分
 */

/**
 *       scheme前缀： bkroute://urlroute.black.com/
 * debug scheme前缀： #~!%^&#debug#~!%^&#://
 */

typedef NS_ENUM(NSInteger, RouteCallbackOperation) {
    RouteCallbackOperationNone,
    RouteCallbackOperationPush,
    RouteCallbackOperationPresent,
    RouteCallbackOperationUtil, //兼容pad, 在pad上present，在phone上push
};

@interface RouteCallback : NSObject
@property (nonatomic, assign) RouteCallbackOperation operation; // 执行的操作类型
@property (nonatomic, assign) CGFloat delay;        // 延时
@property (nonatomic, strong) NSDictionary *params; // 添加参数
@property (nonatomic, assign) BOOL needPop;         // pop一层
@property (nonatomic, assign) BOOL popToRoot;       // pop到root
@property (nonatomic, assign) NSInteger tabIndex;   // tabViewController的选中索引

+ (instancetype)noneCallback;
+ (instancetype)utilCallback;
+ (instancetype)pushCallback;
+ (instancetype)presentCallback;

@end

/**
 *  If you use this lib your UIViewControllers should confirm this protocol
 */
@protocol HJRouteProtocol<NSObject>
@optional
/**
 *  Wheather can open the route
 *
 *  @param uri Route's address
 *
 *  @return The result
 */
+ (BOOL)canRouteUri:(NSString *)uri;

@required

/**
 处理route
 
 @param uri  资源地址
 @param info 参数信息, 应当是个字典，考虑到兼容swift，故这里使用id类型
 
 @return 执行的操作
 */
- (RouteCallback *)willRouteUri:(NSString *)uri info:(id)info;
@end

/**
 *  Route instance
 */
@interface Route : NSObject
/// The pattern of the route
@property (strong, nonatomic) NSString *pattern; // The pattern must start with dash
/// Destination ViewController's class name
@property (strong, nonatomic) NSString *className;
/// Custom action, you can add route by className or block
@property (copy, nonatomic) void (^block)(NSString *path, NSDictionary *info);

+ (instancetype)routeWithPattern:(NSString *)pattern className:(NSString *)className;

+ (instancetype)routeWithPattern:(NSString *)pattern block:(void (^)(NSString *path, NSDictionary *info))block;

/// Prints the entire routing table
- (NSString *)description;
@end



@interface BKRoutes : NSObject

/// Return a global routes manager object
+ (instancetype)defaultRoutes;
/// Add a route to the manager
- (void)addRoute:(Route *)route;

/// Remove a route from the manager
- (void)removeRoute: (Route *)route;
/// Remove a route where match the pattern
- (void)removeRouteWithPattern:(NSString *)pattern;
/// Remove all routes
- (void)clearRoutes;

/// Modify a route's class name
- (void)modifyRouteWithPattern:(NSString *)pattern newClassName:(NSString *)newClassName;

/// Forward the route
- (BOOL)routeUrl:(NSString *)url;
/// Forward the route
- (BOOL)routeUrl:(NSString *)url isPresent:(BOOL)present;

/// 处理路由， uri为资源地址区别于前面连个方法指定的url
+ (BOOL)routeUri:(NSString *)uri withInfo:(NSDictionary *)info;
/// 处理路由
+ (BOOL)routeUri:(NSString *)uri withInfo:(NSDictionary *)info isPresent:(BOOL)present;

/// 显示一个ViewController
- (void)routeViewController:(UIViewController *)vc inParent:(UIViewController *)parent isPresent:(BOOL)present;

/**
 分析url
 
 @param url  待分析的url
 @param path 获取到的url资源地址
 
 @return url的参数
 */
- (NSDictionary *)parseUrl:(NSString *)url path: (NSString **)path;

- (void)printAllRoutes; // Used to debug

#pragma mark - Properties
/// Count of the routes
- (NSInteger)count;
@end

@interface BKRoutes (UrlExtractor)
/// 提取合法的url
+ (NSURL *)getUrlFromDict:(NSDictionary *)info inKey:(NSString *)key;
@end
