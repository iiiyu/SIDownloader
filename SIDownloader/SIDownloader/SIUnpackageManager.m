//
//  SIUnpackageManager.m
//  SIDownloader
//
//  Created by ChenYu Xiao on 12-6-19.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import "SIUnpackageManager.h"
#import "NSFileManager+Tar.h"

@interface SIUnpackageManager()



@end

@implementation SIUnpackageManager
@synthesize arrayUnpackages = _arrayUnpackages;
@synthesize delegate = _delegate;

+ (id)sharedSIUnpackageManager
{
    static SIUnpackageManager *siUnpackageManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{ siUnpackageManager = [[self alloc] init];});
    return siUnpackageManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _arrayUnpackages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addUnpackageTask:(NSString *)paramFilePath toPath:(NSString *)paramDirectory autoDelete:(BOOL)autoDelete
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{  
            // No need to hod onto (retain)  
        [[self delegate] unpackageManagerWillUnpackage:self unpackagePath:paramFilePath];
        });
        //解压代码
        [_arrayUnpackages addObject:paramFilePath];
        [[NSFileManager defaultManager] createFilesAndDirectoriesAtPath:paramDirectory withTarPath:paramFilePath error:nil];

        dispatch_async(dispatch_get_main_queue(), ^{  
            if (autoDelete) {
                [[NSFileManager defaultManager] removeItemAtPath:paramFilePath error:nil];
            }
             [[self delegate] unpackageManagerDidUnpackage:self unpackagePath:paramFilePath];
            [_arrayUnpackages removeObject:paramFilePath];
        }); 
    });
}

- (NSArray *)allUnpackage
{
    return _arrayUnpackages;
}

//- (BOOL)removeFile:(NSString *)filePath
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    return [fileManager removeItemAtPath:filePath error:nil];
//}


@end
