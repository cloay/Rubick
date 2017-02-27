//
//  NSURLSession+RubickSwizzled.m
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

#import "NSObject+RubickSwizzled.h"
#import "NSURLSession+RubickSwizzled.h"
#import "Rubick.h"
#import "RubickProxy.h"
#import "objc/runtime.h"

@implementation NSURLSession (RubickSwizzled)

+ (void)rubickSwizzled {
    //For detail goto https://github.com/datatheorem/TrustKit/
    // Figure out NSURLSession's "real" class
    NSString *NSURLSessionClass;
    if (NSClassFromString(@"NSURLSession") != nil) { // iOS 8+
        NSURLSessionClass = @"NSURLSession";
    } else if (NSClassFromString(@"__NSCFURLSession") != nil) {
        // Pre iOS 8, for some reason hooking NSURLSession doesn't work. We need to use the real/private class __NSCFURLSession
        NSURLSessionClass = @"__NSCFURLSession";
    } else {
        RKLog(@"ERROR: Could not find NSURLSession's class");
        return;
    }
    
    Class cls = object_getClass(NSClassFromString(NSURLSessionClass));
    [self rk_swizzleInstanceMethodWithOriginClass:cls originalSelector:@selector(sessionWithConfiguration:delegate:delegateQueue:) swizzledClass:cls swizzledSelector:@selector(rk_swizzledSessionWithConfiguration:delegate:delegateQueue:)];
    
}

+ (NSURLSession *)rk_swizzledSessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue {
    RubickProxy *aProxy = [[RubickProxy alloc] init];
    aProxy.sessionDelegate = delegate;
    return [self rk_swizzledSessionWithConfiguration:configuration delegate:(id)aProxy delegateQueue:queue];
}

@end
