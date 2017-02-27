//
//  RubickNetworkReachability.h
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

//See Apple's Reachability Sample Code (https://developer.apple.com/library/ios/samplecode/reachability/)
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    RKNetworkStatusNotReachable = 0,
    RKNetworkStatusReachableViaWiFi,
    RKNetworkStatusReachableViaGPRS,
    RKNetworkStatusReachableVia2G,
    RKNetworkStatusReachableVia3G,
    RKNetworkStatusReachableVia4G,
} RKNetworkStatus;

typedef enum : NSInteger{
    RKNetworkCarrierUnknown = 0,
    RKNetworkCarrierChinaMobile,
    RKNetworkCarrierChinaUnicom,
    RKNetworkCarrierChinaTelecom,
    RKNetworkCarrierChinaTietong,
} RKNetworkCarrier;


extern NSString *kNetworkReachabilityChangedNotification;

@interface RubickNetworkReachability : NSObject


/**
 Use to check the reachability of a given host name.
 @param hostName host
 @return RubickNetwork
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;


/**
 Use to check the reachability of a given IP address.
 
 @param hostAddress IP address
 @return RubickNetwork
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;


/**
 Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 
 @return RubickNetwork
 */
+ (instancetype)reachabilityForInternetConnection;



/**
 Start listening for reachability notifications on the current run loop.
 
 @return YES or NO
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

- (RKNetworkStatus)currentReachabilityStatus;
- (RKNetworkCarrier)currentCarrier;

+ (NSString *)getNetworkType:(RKNetworkStatus)status;
+ (NSString *)getCarrierName:(RKNetworkCarrier)carrier;

/**
 WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 
 @return YES or NO
 */
- (BOOL)connectionRequired;


@end
