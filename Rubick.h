//
//  Rubick.h
//  Rubick
//
//  Created by cloay on 2017/1/17.
//  Copyright © 2017年 Cloay. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#define RUBICK_OPEN_DEBUG_KEY @"RUBICK_OPEN_DEBUG"

#define RUBICK_USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define IS_DEBUG [RUBICK_USER_DEFAULTS boolForKey:RUBICK_OPEN_DEBUG_KEY]

#define RUBICK_LOG(format, ...) NSLog((@"%s [line = %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define RKLog(id,...) IS_DEBUG ? RUBICK_LOG(id, ##__VA_ARGS__) : @""

@interface Rubick : NSObject

@property (nonatomic, strong) NSArray *apiUrls;
@property (nonatomic, strong, readonly) NSString *deviceAppInfo;

+ (Rubick *)sharedInstance;


/**
 监控网络
 
 @param urls 要监控的域名
 */
+ (void)startTrackWithUrls:(NSArray *)urls;

/**
 打开调试
 */
+ (void)openDebug;

@end
