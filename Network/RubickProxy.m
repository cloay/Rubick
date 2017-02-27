//
//  RubickProxy.m
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

#import "RubickProxy.h"
#import "RubickProxyImp.h"

@interface RubickProxy()
@property (nonatomic, strong) RubickProxyImp *proxyImp;
@end

@implementation RubickProxy

- (instancetype)init {
    self = [super init];
    if (self) {
        self.proxyImp = [[RubickProxyImp alloc] init];
    }
    return self;
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    if (self.connectionDelegate && [self.connectionDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    
    if (aSelector == @selector(connectionDidFinishLoading:) || aSelector == @selector(connection:didFailWithError:) || aSelector == @selector(connection:didReceiveResponse:) || aSelector == @selector(connection:didReceiveData:) || aSelector == @selector(URLSession:task:didCompleteWithError:) || aSelector == @selector(URLSession:dataTask:didReceiveData:) || aSelector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *aMethodSign = [self.proxyImp methodSignatureForSelector:aSelector];
    if (!aMethodSign && self.connectionDelegate) {
        aMethodSign = [self.connectionDelegate methodSignatureForSelector:aSelector];
    }
    
    if (!aMethodSign && self.sessionDelegate) {
        aMethodSign = [self.sessionDelegate methodSignatureForSelector:aSelector];
    }
    return aMethodSign;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.proxyImp respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.proxyImp];
    }
    
    if (self.connectionDelegate && [self.connectionDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.connectionDelegate];
    }
    
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.sessionDelegate];
    }
}

@end
