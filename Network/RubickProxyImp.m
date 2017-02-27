//
//  RubickProxyImp.m
//  Rubick
//
//  Created by cloay on 2017/1/17.
//  Copyright © 2017年 Cloay. All rights reserved.
//

#import "RubickProxyImp.h"
#import "Rubick.h"
#import "RubickLog.h"
#import "RubickNetworkReachability.h"
#import "NSURLConnection+RubickSwizzled.h"
#import "NSURLSessionTask+RubickSwizzled.h"

@interface RubickProxyImp()<NSURLConnectionDataDelegate,NSURLConnectionDownloadDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLResponse *reponse;
@property (nonatomic, assign) NSUInteger contentSize;
@end

@implementation RubickProxyImp

- (void)saveLogWithStartTime:(NSTimeInterval)startTime request:(NSURLRequest*)request error:(NSError *)error costTime:(NSTimeInterval)doneTime {
    
    NSString *url = request.URL.absoluteString;
    __block BOOL shouldSave = NO;
    [[Rubick sharedInstance].apiUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([url containsString:obj]) {
            shouldSave = YES;
            *stop = YES;
        }
    }];
    
    if (!shouldSave) {
        return;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime/1000];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *startAt = [format stringFromDate:date];
    
    NSInteger responseCode = (self.reponse && [self.reponse isKindOfClass:[NSHTTPURLResponse class]] ) ? ((NSHTTPURLResponse*)self.reponse).statusCode : -1;
    NSString *networkLog = [NSString stringWithFormat:@"start_at:%@, url:%@, method:%@, body_size:%ld, response_code:%ld, content_size:%ld, error:%@, cost_time:%lfms", startAt, request.URL.absoluteString, request.HTTPMethod,  [request.HTTPBody length], responseCode, self.contentSize, error ? [NSString stringWithFormat:@"code = %ld, msg = %@", error.code, error.localizedDescription] : @"empty", doneTime];
    
    RubickLog *rkLog = [RubickLog sharedInstance];
    dispatch_async(rkLog.netQueue, ^{
        
        RubickNetworkReachability *network = [RubickNetworkReachability reachabilityWithHostName:@"www.baidu.com"];
        NSString *networkType = [RubickNetworkReachability getNetworkType:[network currentReachabilityStatus]];
        NSString *carrier = [RubickNetworkReachability getCarrierName:[network currentCarrier]];
        
        NSString *log = [NSString stringWithFormat:@"%@, net:%@, carrier:%@, %@", networkLog, networkType, carrier, [Rubick sharedInstance].deviceAppInfo];
        [rkLog saveLog:log];
    });
}


#pragma mark - NSURLConnectionDataDelegate methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSTimeInterval doneTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSTimeInterval costTime = doneTime - connection.startTime;
    RKLog(@"doneTime = %.3f ms", doneTime);
    RKLog(@"costTime = %lf ms", costTime);
    [self saveLogWithStartTime:connection.startTime request:connection.currentRequest error:error costTime:costTime];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSTimeInterval doneTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSTimeInterval costTime = doneTime - connection.startTime;
    
    [self saveLogWithStartTime:connection.startTime request:connection.currentRequest error:nil costTime:costTime];
    
    RKLog(@"doneTime = %.3f ms", doneTime);
    RKLog(@"costTime = %lf ms", costTime);
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    NSTimeInterval doneTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSTimeInterval costTime = doneTime - connection.startTime;
    
    [self saveLogWithStartTime:connection.startTime request:connection.currentRequest error:nil costTime:costTime];
    
    RKLog(@"doneTime = %.3f ms", doneTime);
    RKLog(@"costTime = %lf ms", costTime);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.reponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    self.contentSize += [data length];
}

#pragma mark - NSURLSessionDataDelegate method
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSTimeInterval doneTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSTimeInterval costTime = doneTime - task.startTime;
    self.reponse = task.response;
    [self saveLogWithStartTime:task.startTime request:task.currentRequest error:nil costTime:costTime];
    
    RKLog(@"doneTime = %.3f ms", doneTime);
    RKLog(@"costTime = %lf ms", costTime);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    self.reponse = response;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    self.contentSize += [data length];
}

@end
