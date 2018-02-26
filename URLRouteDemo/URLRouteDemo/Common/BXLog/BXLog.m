#import "BXLog.h"
#import "BLog.h"

// #define _BXLog(s, ...) \
__BXLog(@"<%@::%d,%@>\n" s, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  NSStringFromSelector(_cmd), ##__VA_ARGS__)

static BOOL _BX_LOG_FLAG = NO;
static BOOL _BX_LOG_INITED = NO;

void _BXLogInit();
void __BXUpdateConfig()
{
    static NSString* logKey = @"logLevel";
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [[NSString alloc] initWithString:[pathArray objectAtIndex:0]];
    NSString* filePath = [path stringByAppendingString:@"/log.properties.plist"];
    
    NSInteger logLevel = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSDictionary* configDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSString* logLevelStr = [configDic objectForKey:logKey];
        if (logLevelStr)
        {
            logLevel = [logLevelStr integerValue];
        }
    }
    
    if (!(_BX_LOG_FLAG = logLevel == 1001))
    {
        [@{logKey:@"0"} writeToFile:filePath atomically:YES];
    }
}

void _BXLogInit()
{
    if (_BX_LOG_INITED)
    {
        return;
    }
    
    _BX_LOG_INITED = YES;
    
    __BXUpdateConfig();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, 15ull * NSEC_PER_SEC),
                              15ull * NSEC_PER_SEC,
                              1ull * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        __BXUpdateConfig();
    });
    dispatch_resume(timer);
}

void __BXLog(NSString* format, ...)
{
    _BXLogInit();
#if (!TARGET_IPHONE_SIMULATOR)
    if (!_BX_LOG_FLAG)
    {
        return;
    }
#endif
    
    va_list argp;
    va_start(argp, format);
    NSLogv(format, argp);
    va_end(argp);
}

void __BXLogM(NSString* format, ...)
{
    _BXLogInit();
#if (!TARGET_IPHONE_SIMULATOR)
    if (!_BX_LOG_FLAG)
    {
        return;
    }
#endif
    
    va_list argp;
    va_start(argp, format);
    NSString* str = [[NSString alloc] initWithFormat:format arguments:argp];
    if (str)
    {
        fprintf(stdout, "%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    va_end( argp );
}

void __BLog(NSString* format, ...)
{
    va_list argp;
    va_start(argp, format);
    NSLogv(format, argp);
    va_end(argp);
}

void __BLogM(NSString* format, ...)
{
    va_list argp;
    va_start(argp, format);
    NSString* str = [[NSString alloc] initWithFormat:format arguments:argp];
    if (str)
    {
        fprintf(stdout, "%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    va_end( argp );
}
