//
//  RubickNetworkReachability.m
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

#import "RubickNetworkReachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString *kNetworkReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";


#pragma mark - Supporting functions

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [RubickNetworkReachability class]], @"info was wrong class in ReachabilityCallback");
    
    RubickNetworkReachability *noteObject = (__bridge RubickNetworkReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kNetworkReachabilityChangedNotification object:noteObject];
}

@implementation RubickNetworkReachability {
    SCNetworkReachabilityRef _reachabilityRef;
}


+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
    RubickNetworkReachability *rkNetwork = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL) {
        rkNetwork = [[self alloc] init];
        if (rkNetwork != NULL) {
            rkNetwork->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return rkNetwork;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    RubickNetworkReachability *rkNetwork = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    if (reachability != NULL) {
        rkNetwork = [[self alloc] init];
        if (rkNetwork != NULL) {
            rkNetwork->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return rkNetwork;
}

+ (instancetype)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

#pragma mark - Start and stop notifier
- (BOOL)startNotifier {
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            return YES;
        }
    }
    return NO;
}

- (void)stopNotifier {
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)dealloc {
    [self stopNotifier];
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}

#pragma mark - Network Flag Handling
- (RKNetworkStatus)currentReachabilityStatus {
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    RKNetworkStatus networkStatus = RKNetworkStatusNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        networkStatus = [self networkStatusForFlags:flags];
    }
    return networkStatus;
}

- (BOOL)connectionRequired {
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

- (RKNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return RKNetworkStatusNotReachable;
    }
    
    RKNetworkStatus networkStatus = RKNetworkStatusNotReachable;
    
    /*
     If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
     */
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        networkStatus = RKNetworkStatusReachableViaWiFi;
    }
    
    /*
     ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
     */
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and no [user] intervention is needed...
         */
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            networkStatus = RKNetworkStatusReachableViaWiFi;
        }
    }
    
    /*
     ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
     */
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentStatus = info.currentRadioAccessTechnology;
        
        if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
            networkStatus = RKNetworkStatusReachableViaGPRS;
        } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x] || [currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
            networkStatus = RKNetworkStatusReachableVia2G;
        } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA] || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA] || [currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA] || [currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            networkStatus = RKNetworkStatusReachableVia3G;
        } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]) {
            networkStatus = RKNetworkStatusReachableVia4G;
        }
    }
    return networkStatus;
}



/**
 Get carrier type, https://en.wikipedia.org/wiki/Mobile_country_code#China_-_CN
 
 @return RKNetworkCarrier
 */
- (RKNetworkCarrier)currentCarrier {
    RKNetworkCarrier carrier = RKNetworkCarrierUnknown;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc]init];
    CTCarrier *cellularProvider = networkInfo.subscriberCellularProvider;
    NSString *mobileNetworkCode = cellularProvider.mobileNetworkCode;
    if ([mobileNetworkCode isEqualToString:@"00"] || [mobileNetworkCode isEqualToString:@"02"] || [mobileNetworkCode isEqualToString:@"07"] ) {
        carrier = RKNetworkCarrierChinaMobile;
    } else if ([mobileNetworkCode isEqualToString:@"01"] || [mobileNetworkCode isEqualToString:@"06"] ) {
        carrier = RKNetworkCarrierChinaUnicom;
    } else if ([mobileNetworkCode isEqualToString:@"03"] || [mobileNetworkCode isEqualToString:@"05"] ) {
        carrier = RKNetworkCarrierChinaTelecom;
    } else if ([mobileNetworkCode isEqualToString:@"20"]) {
        carrier = RKNetworkCarrierChinaTietong;
    }
    return carrier;
}

+ (NSString *)getNetworkType:(RKNetworkStatus)status {
    NSString *nType;
    switch (status) {
            case RKNetworkStatusNotReachable:
                nType = @"NotReachable";
            break;
            case RKNetworkStatusReachableViaWiFi:
                nType = @"WIFI";
            break;
            case RKNetworkStatusReachableViaGPRS:
                nType = @"GPRS";
            break;
            case RKNetworkStatusReachableVia2G:
                nType = @"2G";
            break;
            case RKNetworkStatusReachableVia3G:
                nType = @"3G";
            break;
            case RKNetworkStatusReachableVia4G:
                nType = @"4G";
            break;
        default:
                nType = @"NotReachable";
            break;
    }
    return nType;
}

+ (NSString *)getCarrierName:(RKNetworkCarrier)carrier {
    NSString *cName;
    switch (carrier) {
            case RKNetworkCarrierUnknown:
                cName = @"Unknown";
            break;
            case RKNetworkCarrierChinaMobile:
                cName = @"ChinaMobile";
            break;
            case RKNetworkCarrierChinaUnicom:
                cName = @"ChinaUnicom";
            break;
            case RKNetworkCarrierChinaTelecom:
                cName = @"ChinaTelecom";
            break;
            case RKNetworkCarrierChinaTietong:
                cName = @"ChinaTietong";
            break;
        default:
                cName = @"Unknown";
            break;
    }
    return cName;
}

@end
