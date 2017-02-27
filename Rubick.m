//
//  Rubick.m
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

#import "Rubick.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "NSURLConnection+RubickSwizzled.h"
#import "NSURLSession+RubickSwizzled.h"
#import "NSURLSessionTask+RubickSwizzled.h"

@implementation Rubick

+ (Rubick *)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    [RUBICK_USER_DEFAULTS setBool:NO forKey:RUBICK_OPEN_DEBUG_KEY];
    [self pepareDeviceAppInfo];
    return self;
}


+ (void)startTrackWithUrls:(NSArray *)urls {
    //替换NSURLConnection相关方法
    [NSURLConnection rubickSwizzled];
    //替换NSURLSession相关方法
    [NSURLSession rubickSwizzled];
    [NSURLSessionTask rubickSwizzled];
    
    Rubick *rubick = [Rubick sharedInstance];
    rubick.apiUrls = urls;
}

+ (void)openDebug {
    [RUBICK_USER_DEFAULTS setBool:YES forKey:RUBICK_OPEN_DEBUG_KEY];
}

- (void)pepareDeviceAppInfo {
    NSString *deviceName = [self getDeviceName];
    NSString *osVer = [[UIDevice currentDevice] systemVersion];
    
    //App
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic valueForKey:@"CFBundleDisplayName"];
    NSString *appVer = [infoDic valueForKey:@"CFBundleShortVersionString"];
    
    _deviceAppInfo = [NSString stringWithFormat:@"device:%@, os:%@, appN:%@, appV:%@", deviceName, osVer, appName, appVer];
}


- (NSString *)getDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone6sPlus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhoneSE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone7Plus";
    
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPodTouch1G";
    
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPodTouch2G";
    
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPodTouch3G";
    
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPodTouch4G";
    
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPodTouch5G";
    
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad1G";
    
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPadMini1G";
    
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPadMini1G";
    
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPadMini1G";
    
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad3";
    
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad3";
    
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad3";
    
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad4";
    
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad4";
    
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad4";
    
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPadAir";
    
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPadAir";
    
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPadAir";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPadMini2G";
    
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPadMini2G";
    
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPadMini2G";
    
    if ([platform isEqualToString:@"i386"]) return @"iPhoneSimulator";
    
    if ([platform isEqualToString:@"x86_64"]) return @"iPhoneSimulator";
    
    return platform;
}
@end
