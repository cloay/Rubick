//
//  NSURLSessionTask+RubickSwizzled.m
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

#import "NSURLSessionTask+RubickSwizzled.h"
#import <objc/runtime.h>
#import "Rubick.h"

@implementation NSURLSessionTask (RubickSwizzled)

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
    //For detail goto https://github.com/Alamofire/Alamofire
    if (NSClassFromString(@"NSURLSessionTask")) {
        /**
         iOS 7 and iOS 8 differ in NSURLSessionTask implementation, which makes the next bit of code a bit tricky.
         Many Unit Tests have been built to validate as much of this behavior has possible.
         Here is what we know:
         - NSURLSessionTasks are implemented with class clusters, meaning the class you request from the API isn't actually the type of class you will get back.
         - Simply referencing `[NSURLSessionTask class]` will not work. You need to ask an `NSURLSession` to actually create an object, and grab the class from there.
         - On iOS 7, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `__NSCFURLSessionTask`.
         - On iOS 8, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `NSURLSessionTask`.
         - On iOS 7, `__NSCFLocalSessionTask` and `__NSCFURLSessionTask` are the only two classes that have their own implementations of `resume` and `suspend`, and `__NSCFLocalSessionTask` DOES NOT CALL SUPER. This means both classes need to be swizzled.
         - On iOS 8, `NSURLSessionTask` is the only class that implements `resume` and `suspend`. This means this is the only class that needs to be swizzled.
         - Because `NSURLSessionTask` is not involved in the class hierarchy for every version of iOS, its easier to add the swizzled methods to a dummy class and manage them there.
         
         Some Assumptions:
         - No implementations of `resume` or `suspend` call super. If this were to change in a future version of iOS, we'd need to handle it.
         - No background task classes override `resume` or `suspend`
         
         The current solution:
         1) Grab an instance of `__NSCFLocalDataTask` by asking an instance of `NSURLSession` for a data task.
         2) Grab a pointer to the original implementation of `af_resume`
         3) Check to see if the current class has an implementation of resume. If so, continue to step 4.
         4) Grab the super class of the current class.
         5) Grab a pointer for the current class to the current implementation of `resume`.
         6) Grab a pointer for the super class to the current implementation of `resume`.
         7) If the current class implementation of `resume` is not equal to the super class implementation of `resume` AND the current implementation of `resume` is not equal to the original implementation of `af_resume`, THEN swizzle the methods
         8) Set the current class to the super class, and repeat steps 3-8
         */
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        IMP rkResumeIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(rk_resume)));
        Class currentClass = [localDataTask class];
        
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            if (classResumeIMP != superclassResumeIMP &&
                rkResumeIMP != classResumeIMP) {
                [self swizzleMethod:currentClass originalSelector:@selector(resume) swizzledClass:self swizzledSelector:@selector(rk_resume)];
            }
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}


- (void)rk_resume {
    [self rk_resume];
    self.startTime = [[NSDate date] timeIntervalSince1970]*1000;
    RKLog(@"startTime = %.3f ms", self.startTime);
}


+ (void)swizzleMethod:(Class)originCls originalSelector:(SEL)originalSelector swizzledClass:(Class)swizzledCls swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(originCls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector);
    
    // class_addMethod will fail if original method already exists, the method doesn’t exist and we just added one
    BOOL didAddMethod = class_addMethod(originCls, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        swizzledMethod = class_getInstanceMethod(originCls, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
