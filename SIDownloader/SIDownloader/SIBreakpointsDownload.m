////
////  SIBreakpointsDownload.m
////  SIDownloader
////
////  Created by ChenYu Xiao on 12-6-13.
////  Copyright (c) 2012年 sumi. All rights reserved.
////
//
//#import "SIBreakpointsDownload.h"
//
//@implementation SIBreakpointsDownload
//
////传入要下载地址的url，断点下载的临时文件的路径， 完成以后的路径
//- (MKNetworkOperation *) downloadFatAssFileFrom:(NSString *)paramRemoteURL
//                                     toTempFile:(NSString *)paramTempFileName 
//                                    andRealFile:(NSString *)paramRealFileName
//{
//    MKNetworkOperation *op = [self operationWithURLString:paramRemoteURL
//                                                   params:nil 
//                                               httpMethod:@"GET"];
//    // 判断之前是否下载过 如果有下载重新构造Header
//    if ([self isFileExist:paramTempFileName]) {
//        [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:paramTempFileName append:YES]];
//        NSMutableDictionary *newHeadersDict = [[NSMutableDictionary alloc] init];
//        NSString *userAgentString = [NSString stringWithFormat:@"%@/%@", 
//                                     [[[NSBundle mainBundle] infoDictionary] 
//                                      objectForKey:(NSString *)kCFBundleNameKey], 
//                                     [[[NSBundle mainBundle] infoDictionary] 
//                                      objectForKey:(NSString *)kCFBundleVersionKey]];
//        [newHeadersDict setObject:userAgentString forKey:@"User-Agent"];
//
//        unsigned long long fileSize = [self isFileSize:paramTempFileName];
//        NSString *headerRange = [NSString stringWithFormat:@"bytes=%llu-", fileSize];
//        [newHeadersDict setObject:headerRange forKey:@"Range"];
//        [op addHeaders:newHeadersDict];
//        
//    }else {
//        [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:paramTempFileName append:YES]];
//        NSMutableDictionary *newHeadersDict = [[NSMutableDictionary alloc] init];
//        NSString *userAgentString = [NSString stringWithFormat:@"%@/%@", 
//                                     [[[NSBundle mainBundle] infoDictionary] 
//                                      objectForKey:(NSString *)kCFBundleNameKey], 
//                                     [[[NSBundle mainBundle] infoDictionary] 
//                                      objectForKey:(NSString *)kCFBundleVersionKey]];
//        
//        [newHeadersDict setObject:userAgentString forKey:@"User-Agent"];
//        [op addHeaders:newHeadersDict];
//    }
//    
//    // 放入队列进行下载
//    [self enqueueOperation:op];
//    
//    // 下载完成以后mv临时文件为正式文件
//    [op onCompletion:^(MKNetworkOperation* completedRequest) {
//        NSFileManager *fm = [[NSFileManager alloc] init];
//        [fm removeItemAtPath:paramRealFileName error:nil];
//        [fm moveItemAtPath:paramTempFileName toPath:paramRealFileName error:nil];
//        NSLog(@"1");
//        
//    }
//             onError:^(NSError* error) {
//                 DLog(@"%@", error);
//                 [UIAlertView showWithError:error];
//             }];
//    return op;
//}
//
//- (MKNetworkOperation *) downloadFatAssFileFrom:(NSString *)paramRemoteURL toTempFile:(NSString *) paramTempFileName andRealFile:(NSString *) paramRealFileName toUnzipFileName:(NSString *) paramUnzipFileName
//{
//    return nil;
//}
//
//- (BOOL)isFileExist:(NSString *)filePath
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    return [fileManager fileExistsAtPath:filePath];
//}
//
//- (unsigned long long)isFileSize:(NSString *)filePath
//{
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    NSDictionary *dict = [fileManager attributesOfItemAtPath:filePath error:nil];
//    return (unsigned long long)[dict fileSize];
//}
//
//@end


//
//  SIBreakpointsDownload.m
//  SIDownloader
//
//  Created by ChenYu Xiao on 12-6-13.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import "SIBreakpointsDownload.h"

@implementation SIBreakpointsDownload

//- (BOOL)isFileExist:(NSString *)filePath
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    return [fileManager fileExistsAtPath:filePath];
//}
//
//- (unsigned long long)isFileSize:(NSString *)filePath
//{
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    NSDictionary *dict = [fileManager attributesOfItemAtPath:filePath error:nil];
//    return (unsigned long long)[dict fileSize];
//}



+ (SIBreakpointsDownload *) operationWithURLString:(NSString *) urlString
                                            params:(NSMutableDictionary *) body
                                        httpMethod:(NSString *)method 
                                      tempFilePath:(NSString *)tempFilePath
                                  downloadFilePath:(NSString *)downloadFilePath
                                       rewriteFile:(BOOL)rewrite;
{
    // 获得临时文件的路径
//    NSString  *tempDoucment = NSTemporaryDirectory();
//    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
//    NSRange lastCharRange = [filePath rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
//    NSString *tempFilePath = [NSString stringWithFormat:@"%@%@.temp", tempDoucment, [filePath substringFromIndex:lastCharRange.location + 1]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *newHeadersDict = [[NSMutableDictionary alloc] init];

    // 如果是重新下载，就要删除之前下载过的文件
    if (rewrite && [fileManager fileExistsAtPath:tempFilePath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:tempFilePath error:&error];
        if (error) {
            NSLog(@"%@ file remove failed!\nError:%@", tempFilePath, error);
        }
    }else if(rewrite && [fileManager fileExistsAtPath:downloadFilePath]){
        NSError *error = nil;
        [fileManager removeItemAtPath:downloadFilePath error:&error];
        if (error) {
            NSLog(@"%@ file remove failed!\nError:%@", downloadFilePath, error);
        }
    }
    
    if ([fileManager fileExistsAtPath:downloadFilePath]) {
        return nil;
    }else {
        
        NSString *userAgentString = [NSString stringWithFormat:@"%@/%@", 
                                     [[[NSBundle mainBundle] infoDictionary] 
                                      objectForKey:(NSString *)kCFBundleNameKey], 
                                     [[[NSBundle mainBundle] infoDictionary] 
                                      objectForKey:(NSString *)kCFBundleVersionKey]];
        [newHeadersDict setObject:userAgentString forKey:@"User-Agent"];
        
        // 判断之前是否下载过 如果有下载重新构造Header
        if ([fileManager fileExistsAtPath:tempFilePath]) {
            NSError *error = nil;
            unsigned long long fileSize = [[fileManager attributesOfItemAtPath:tempFilePath error:&error] fileSize];
            if (error) {
                NSLog(@"get %@ fileSize failed!\nError:%@", tempFilePath, error);
            }
            NSString *headerRange = [NSString stringWithFormat:@"bytes=%llu-", fileSize];
            [newHeadersDict setObject:headerRange forKey:@"Range"];
            
        }
        
        // 初始化opertion
        SIBreakpointsDownload *operation = [[SIBreakpointsDownload alloc] initWithURLString:urlString params:body httpMethod:method];
        [operation addDownloadStream:[NSOutputStream outputStreamToFileAtPath:tempFilePath append:YES]];
        
        [operation addHeaders:newHeadersDict];
        
        return operation;
    }
}

//-(void) prepareHeaders:(SIBreakpointsDownload*) operation {
//    
//    [operation addHeaders:self.customHeaders];
//}
//

@end

