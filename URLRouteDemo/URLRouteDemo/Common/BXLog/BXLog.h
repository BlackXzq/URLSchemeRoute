/*
 * BXLog
 * Output log when using simulator.
 * Manully output log  when using ios device.
 * To enable the log on ios device, 
 * please set logLevel to "1001" in "Documents/log.properties.plist".
 */
#import "BXLogDefine.h"

/*
 * Default log format like NSLog
 *
 * BXLog(@"hello %@", @"world!");
 * 1970-01-01 00:00:00.000 AppName[3238:60b] hello world!
 */
#define BXLog _BXLog

/*
 * Only show the words without other information
 *
 * BXLogM(@"hello %@", @"world!");
 * hello world!
 */
#define BXLogM _BXLogM


#define BXFileLog _BXFileLog


