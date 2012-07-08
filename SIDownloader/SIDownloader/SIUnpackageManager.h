//
//  SIUnpackageManager.h
//  SIDownloader
//
//  Created by ChenYu Xiao on 12-6-19.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SIUnpackageManager;

//Define the protocol for the delegate
@protocol SIUnpackageManagerDelegate

- (void)unpackageManagerWillUnpackage:(SIUnpackageManager *)siUnpackageManager 
                        unpackagePath:(NSString *)paramFilePath;

- (void)unpackageManagerDidUnpackage:(SIUnpackageManager *)siUnpackageManager 
                       unpackagePath:(NSString *)paramFilePath;
@end

@interface SIUnpackageManager : NSObject{
    id<SIUnpackageManagerDelegate> delegate;
}

@property (nonatomic, strong) NSMutableArray *arrayUnpackages;

@property (nonatomic, assign) id<SIUnpackageManagerDelegate> delegate;

+ (id)sharedSIUnpackageManager;

- (void)addUnpackageTask:(NSString *)paramFilePath 
                  toPath:(NSString *)paramDirectory
              autoDelete:(BOOL)autoDelete;

- (NSArray *)allUnpackage;

@end
