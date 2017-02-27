//
//  NSObject+RubickSwizzled.h
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

@interface NSObject (RubickSwizzled)


/**
 交换实例方法
 
 @param originCls 原始的类
 @param originalSel 原始的方法
 @param swizzledCls 要交换的方法所在的类
 @param swizzledSel 交换成的方法
 */
+ (void)rk_swizzleInstanceMethodWithOriginClass:(Class)originCls originalSelector:(SEL)originalSel swizzledClass:(Class)swizzledCls swizzledSelector:(SEL)swizzledSel;


/**
 交换类方法
 
 @param originCls 原始的类
 @param originalSel 原始的方法
 @param swizzledCls 要交换的方法所在的类
 @param swizzledSel 交换成的方法
 */
+ (void)rk_swizzleClassMethodWithOriginClass:(Class)originCls originalSelector:(SEL)originalSel swizzledClass:(Class)swizzledCls swizzledSelector:(SEL)swizzledSel;

@end
