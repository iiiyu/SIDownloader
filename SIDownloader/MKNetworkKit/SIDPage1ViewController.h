//
//  SIDPage1ViewController.h
//  SIDownloader
//
//  Created by ChenYu Xiao on 12-7-8.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIDownloadManager.h"
#import "SIBreakpointsDownload.h"

@interface SIDPage1ViewController : UIViewController<SIDownloadManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonDownloadOne;
@property (weak, nonatomic) IBOutlet UIButton *buttonPauseOne;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;

@property (weak, nonatomic) IBOutlet UIProgressView *progressViewOne;
@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteOne;

@property (weak, nonatomic) IBOutlet UIButton *buttonDownloadTwo;
@property (weak, nonatomic) IBOutlet UIButton *buttonPauseTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewTwo;
@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteTwo;


@end
