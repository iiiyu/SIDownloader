////
////  SIBreakpointsDownload.h
////  SIDownloader
////
////  Created by ChenYu Xiao on 12-6-13.
////  Copyright (c) 2012年 sumi. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
//@interface SIBreakpointsDownload : MKNetworkEngine
//
//- (MKNetworkOperation *) downloadFatAssFileFrom:(NSString *)paramRemoteURL toTempFile:(NSString *) paramTempFileName andRealFile:(NSString *) paramRealFileName;
//
//- (MKNetworkOperation *) downloadFatAssFileFrom:(NSString *)paramRemoteURL toTempFile:(NSString *) paramTempFileName andRealFile:(NSString *) paramRealFileName toUnzipFileName:(NSString *) paramUnzipFileName;
//
//@end



//
//  SIBreakpointsDownload.h
//  SIDownloader
//
//  Created by ChenYu Xiao on 12-6-13.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIBreakpointsDownload : MKNetworkOperation

+ (SIBreakpointsDownload *) operationWithURLString:(NSString *) urlString
                                            params:(NSMutableDictionary *) body
                                        httpMethod:(NSString *)method 
                                      tempFilePath:(NSString *)tempFilePath
                                  downloadFilePath:(NSString *)downloadFilePath
                                       rewriteFile:(BOOL)rewrite;



//- (MKNetworkOperation *) downloadFatAssFileFrom:(NSString *)paramRemoteURL toTempFile:(NSString *) paramTempFileName andRealFile:(NSString *) paramRealFileName;
//
//- (MKNetworkOperation *) downloadFatAssFileFrom:(NSString *)paramRemoteURL toTempFile:(NSString *) paramTempFileName andRealFile:(NSString *) paramRealFileName toUnzipFileName:(NSString *) paramUnzipFileName;

@end

