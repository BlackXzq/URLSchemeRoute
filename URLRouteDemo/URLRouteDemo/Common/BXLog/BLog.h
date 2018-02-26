/*
 * BXLog
 * Output log always.
 */
#import "BXLogDefine.h"

/*
 * Default log format like NSLog
 *
 * BXLogS(@"hello %@", @"world!");
 * 1970-01-01 00:00:00.000 AppName[3238:60b] hello world!
 */
#define BLog _BLog

/*
 * Only show the words without other information
 *
 * BLogM(@"hello %@", @"world!");
 * hello world!
 */
#define BLogM _BLogM
