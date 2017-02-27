//
//  RubickLog.m
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

#import <UIKit/UIKit.h>
#import "RubickLog.h"
#import "Rubick.h"

@interface RubickLog()

@property (nonatomic, strong) NSString *logDirPath;
@property (nonatomic, strong) NSString *currentLogFile;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

static NSData *lineBreakData;

@implementation RubickLog

+ (RubickLog *)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        lineBreakData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSString *fullNamespace = @"com.cloay.Rubick.log";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.logDirPath = [paths[0] stringByAppendingPathComponent:fullNamespace];
        
        self.netQueue = dispatch_queue_create("com.cloay.Rubick.netQueue", DISPATCH_QUEUE_CONCURRENT);
        
        self.ioQueue = dispatch_queue_create("com.cloay.Rubick", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(_ioQueue, ^{
            _fileManager = [NSFileManager defaultManager];
        });
        
        //app退出时关闭日志文件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeLogFile) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)saveLog:(NSString *)log {
    if (!log) {
        return;
    }
    RKLog(@"log = %@", log);
    dispatch_async(self.ioQueue, ^{
        //检查日志目录是否存在，没有则创建
        NSString *dirPath = self.logDirPath;
        if (![self.fileManager fileExistsAtPath:dirPath]) {
            [self.fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        //检查当天的日志文件是否存在，没有则创建
        NSDate *date = [NSDate date];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy_MM_dd";
        NSString *dateStr = [format stringFromDate:date];
        NSString *fileName = [dateStr stringByAppendingString:@".log"];
        NSString *logFile = [dirPath stringByAppendingPathComponent:fileName];
        
        //如果当天的日志文件还没有创建，或者日期更换时
        if (!self.currentLogFile ||(self.currentLogFile && ![self.currentLogFile isEqualToString:logFile])) {
            //先关闭的前一天日志文件
            [self closeLogFile];
            
            self.currentLogFile = logFile;
            //创建当日的日志文件
            if (![self.fileManager fileExistsAtPath:self.currentLogFile]) {
                [self.fileManager createFileAtPath:self.currentLogFile contents:nil attributes:nil];
            }
            //打开日志文件
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.currentLogFile];
            self.fileHandle = fileHandle;
            [self.fileHandle seekToEndOfFile];
        }
        
        //将日志写入
        [self.fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        [self.fileHandle writeData:lineBreakData];//换行
    });
}

- (void)closeLogFile {
    if (self.fileHandle) {
        [self.fileHandle closeFile];
        self.fileHandle = nil;
    }
}

@end
