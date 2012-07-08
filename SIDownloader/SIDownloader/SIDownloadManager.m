//
//  SIDownloadManager.m
//  MKTestDownload
//
//  Created by ChenYu Xiao on 12-6-13.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import "SIDownloadManager.h"
#import "SIBreakpointsDownload.h"


@interface SIDownloadManager()

@property (strong, nonatomic) NSMutableArray *downloadArray;

@end

@implementation SIDownloadManager
@synthesize downloadArray = _downloadArray;
@synthesize delegate = _delegate;


+ (id)sharedSIDownloadManager
{
    static SIDownloadManager *siDownloadManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{ siDownloadManager = [[self alloc] init];});
    return siDownloadManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.downloadArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)addDownloadFileTaskInQueue:(NSString *)paramURL 
                        toFilePath:(NSString *)paramFilePath
                  breakpointResume:(BOOL)paramResume
                       rewriteFile:(BOOL)paramRewrite
{
    
    // 获得临时文件的路径
    NSString  *tempDoucment = NSTemporaryDirectory();
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSRange lastCharRange = [paramFilePath rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
    NSString *tempFilePath = [NSString stringWithFormat:@"%@%@.temp", tempDoucment, [paramFilePath substringFromIndex:lastCharRange.location + 1]];
    NSLog(@"###tempFilePath:%@", tempFilePath);
    
    SIBreakpointsDownload *operation = [SIBreakpointsDownload operationWithURLString:paramURL 
                                                                              params:nil 
                                                                          httpMethod:@"GET" 
                                                                        tempFilePath:tempFilePath 
                                                                    downloadFilePath:paramFilePath 
                                                                         rewriteFile:paramRewrite];
    // 如果已经存在下载文件 operation返回nil,否则把operation放入下载队列当中
    BOOL existDownload = NO;
    for (SIBreakpointsDownload *sibd in self.downloadArray) {
        if ([sibd.url isEqualToString:operation.url]) {
            existDownload = YES;
            NSLog(@"YES");
        }
    }
    
    if (existDownload) {
        // delegate
        [[self delegate] downloadManagerDownloadExist:self withURL:paramURL];
    } else if (operation == nil) {
        [[self delegate] downloadManagerDownloadDone:self withURL:paramURL];
    } else { 
        [self enqueueOperation:operation];
        [self.downloadArray addObject:operation];
        
        [operation onDownloadProgressChanged:^(double progress){
            [[self delegate] downloadManager:self withOperation:operation changeProgress:progress];
        }];
        
        [operation onCompletion:^(MKNetworkOperation *completedOperation) {
            
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSError *error = nil;
            
            // 下载完成以后 先删除之前的文件 然后mv新的文件
            if ([fileManager fileExistsAtPath:paramFilePath]) {
                [fileManager removeItemAtPath:paramFilePath error:&error];
                if (error) {
                    NSLog(@"remove %@ file failed!\nError:%@", paramFilePath, error);
                    exit(-1);
                }     
            }
            
            [fileManager moveItemAtPath:tempFilePath toPath:paramFilePath error:&error];
            if (error) {
                NSLog(@"move %@ file to %@ file is failed!\nError:%@", tempFilePath, paramFilePath, error);
                exit(-1);
            }
 
            [[self delegate] downloadManagerDidComplete:self withOperation:(SIBreakpointsDownload *)completedOperation];
            [self.downloadArray removeObject:operation];
            
        } onError:^(NSError *error) {
            [[self delegate] downloadManagerError:self
                                          withURL:paramURL 
                                        withError:error];
            [self.downloadArray removeObject:operation];
        }];
    }
    
}

- (void)cancelDownloadFileTaskInQueue:(NSString *)paramURL
{
    SIBreakpointsDownload *deleteOperation = nil;
    for (SIBreakpointsDownload *sibd in self.downloadArray) {
        if ([sibd.url isEqualToString:paramURL]) {
            deleteOperation = sibd;
        }
    }
    [[self delegate] downloadManagerPauseTask:self withURL:paramURL];
    [deleteOperation cancel];
    [self.downloadArray removeObject:deleteOperation];
}

- (void)cancelAllDonloads
{
    for (SIBreakpointsDownload *op in self.downloadArray) {
        [op cancel];
    }
    [self.downloadArray removeAllObjects];
}

- (NSArray *)allDownloads
{
    return self.downloadArray;
}

@end
