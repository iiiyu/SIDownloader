//
//  SIDownloadManager.h
//  MKTestDownload
//
//  Created by ChenYu Xiao on 12-6-13.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIBreakpointsDownload;
@class SIDownloadManager;

//Define the protocol for the delegate
@protocol SIDownloadManagerDelegate
// 改变progress
- (void)downloadManager:(SIDownloadManager *)siDownloadManager 
          withOperation:(SIBreakpointsDownload *)paramOperation 
         changeProgress:(double)paramProgress;
//下载完成时
- (void)downloadManagerDidComplete:(SIDownloadManager *)siDownloadManager 
                     withOperation:(SIBreakpointsDownload *)paramOperation;
//下载错误
- (void)downloadManagerError:(SIDownloadManager *)siDownloadManager
                     withURL:(NSString *)paramURL
                   withError:(NSError *)paramError;
//下载任务已经存在
- (void)downloadManagerDownloadExist:(SIDownloadManager *)siDwonloadManager
                             withURL:(NSString *)paramURL;
//下载文件已经存在
- (void)downloadManagerDownloadDone:(SIDownloadManager *)siDownloadManager
                            withURL:(NSString *)paramURL;
//暂停下载
- (void)downloadManagerPauseTask:(SIDownloadManager *)siDownloadManager 
                         withURL:(NSString *)paramURL;
@end

@interface SIDownloadManager : MKNetworkEngine
{
    id<SIDownloadManagerDelegate> delegate;
}

@property (nonatomic, assign) id  <SIDownloadManagerDelegate> delegate;

+ (id)sharedSIDownloadManager;

- (void)cancelAllDonloads;

- (void)addDownloadFileTaskInQueue:(NSString *)paramURL 
                        toFilePath:(NSString *)paramFilePath
                  breakpointResume:(BOOL)paramResume
                       rewriteFile:(BOOL)paramRewrite;

- (void)cancelDownloadFileTaskInQueue:(NSString *)paramURL;

- (NSArray *)allDownloads;


@end


