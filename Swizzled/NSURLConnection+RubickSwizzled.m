//
//  NSURLConnection+RubickSwizzled.m
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

#import "NSURLConnection+RubickSwizzled.h"
#import <objc/runtime.h>
#import "NSObject+RubickSwizzled.h"
#import "Rubick.h"
#import "RubickProxy.h"

@implementation NSURLConnection (RubickSwizzled)

- (NSTimeInterval)startTime {
    id object = objc_getAssociatedObject(self, @"startTime");
    return [object doubleValue];
}


- (void)setStartTime:(NSTimeInterval)startTime {
    [self willChangeValueForKey:@"startTime"];
    objc_setAssociatedObject(self, @"startTime", [NSNumber numberWithDouble:startTime], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"startTime"];
}


+ (void)rubickSwizzled {
    Class cls = [self class];
    [self rk_swizzleInstanceMethodWithOriginClass:cls originalSelector:@selector(start) swizzledClass:cls swizzledSelector:@selector(rk_start)];
    
    [self rk_swizzleInstanceMethodWithOriginClass:cls originalSelector:@selector(initWithRequest:delegate:startImmediately:) swizzledClass:cls swizzledSelector:@selector(rk_swizzledInitWithRequest:delegate:startImmediately:)];
    
    [self rk_swizzleInstanceMethodWithOriginClass:cls originalSelector:@selector(initWithRequest:delegate:) swizzledClass:cls swizzledSelector:@selector(rk_swizzledInitWithRequest:delegate:)];
    
    [self rk_swizzleInstanceMethodWithOriginClass:cls originalSelector:@selector(connectionWithRequest:delegate:) swizzledClass:cls swizzledSelector:@selector(rk_swizzledConnectionWithRequest:delegate:)];
}


#pragma mark - 要替换的方法包括启动和初始化方法
- (void)rk_start {
    [self rk_start];
    self.startTime = [[NSDate date] timeIntervalSince1970]*1000;
    RKLog(@"startTime = %.3f ms", self.startTime);
}

- (nullable instancetype)rk_swizzledInitWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate startImmediately:(BOOL)startImmediately {
    RubickProxy *rProxy = [[RubickProxy alloc] init];
    rProxy.connectionDelegate = delegate;
    return [self rk_swizzledInitWithRequest:request delegate:rProxy startImmediately:startImmediately];
}

- (nullable instancetype)rk_swizzledInitWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate {
    RubickProxy *rProxy = [[RubickProxy alloc] init];
    rProxy.connectionDelegate = delegate;
    return [self rk_swizzledInitWithRequest:request delegate:rProxy];
}

+ (nullable NSURLConnection*)rk_swizzledConnectionWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate {
    RubickProxy *rProxy = [[RubickProxy alloc] init];
    rProxy.connectionDelegate = delegate;
    return [self rk_swizzledConnectionWithRequest:request delegate:rProxy];
}

@end
