//
//  SIDPage1ViewController.m
//  SIDownloader
//
//  Created by ChenYu Xiao on 12-7-8.
//  Copyright (c) 2012年 sumi. All rights reserved.
//

#import "SIDPage1ViewController.h"

NSString *urlOne = @"http://dl_dir.qq.com/qqfile/qq/QQforMac/QQ_V2.1.0.dmg";
NSString *urlTwo = @"http://dl_dir.qq.com/qqfile/qq/QQforMac/QQ_V1.4.1.dmg";

@interface SIDPage1ViewController ()
@property (strong, nonatomic) SIDownloadManager *siDownloadManager;

@end

@implementation SIDPage1ViewController
@synthesize buttonDownloadOne = _buttonDownloadOne;
@synthesize buttonPauseOne = _buttonPauseOne;
@synthesize labelOne = _labelOne;
@synthesize progressViewOne = _progressViewOne;
@synthesize buttonDeleteOne = _buttonDeleteOne;
@synthesize buttonDownloadTwo = _buttonDownloadTwo;
@synthesize buttonPauseTwo = _buttonPauseTwo;
@synthesize labelTwo = _labelTwo;   
@synthesize progressViewTwo = _progressViewTwo;
@synthesize buttonDeleteTwo = _buttonDeleteTwo;
@synthesize siDownloadManager = _siDownloadManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _siDownloadManager = [SIDownloadManager sharedSIDownloadManager];

}

- (void)viewDidUnload
{
    [self setButtonDownloadOne:nil];
    [self setButtonPauseOne:nil];
    [self setLabelOne:nil];
    [self setProgressViewOne:nil];
    [self setButtonDownloadTwo:nil];
    [self setButtonPauseTwo:nil];
    [self setLabelTwo:nil];
    [self setProgressViewTwo:nil];
    [self setButtonDeleteOne:nil];
    [self setButtonDeleteTwo:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _siDownloadManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_siDownloadManager setDelegate:nil];
    [super viewWillDisappear:animated];
}


#pragma mark - button action
- (IBAction)downloadOneAction:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"2.1.dmg"];
    
    [_siDownloadManager addDownloadFileTaskInQueue:urlOne 
                                        toFilePath:downloadPath 
                                  breakpointResume:YES 
                                       rewriteFile:NO];
}

- (IBAction)pauseOneAction:(id)sender {
    [_siDownloadManager cancelDownloadFileTaskInQueue:urlOne];
}

- (IBAction)deleteOneAction:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"2.1.dmg"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:downloadPath]) {
        [fileManager removeItemAtPath:downloadPath error:nil];
    }
}

- (IBAction)downloadTwoAction:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"1.4.dmg"];
    
    [_siDownloadManager addDownloadFileTaskInQueue:urlTwo 
                                        toFilePath:downloadPath 
                                  breakpointResume:YES 
                                       rewriteFile:NO];
}

- (IBAction)pauseTwoAction:(id)sender {
    [_siDownloadManager cancelDownloadFileTaskInQueue:urlTwo];
}

- (IBAction)deleteTwoAction:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"1.4.dmg"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:downloadPath]) {
        [fileManager removeItemAtPath:downloadPath error:nil];
    }
}



#pragma mark - SIDownloadManagerDelegate
- (void)downloadManager:(SIDownloadManager *)siDownloadManager
          withOperation:(SIBreakpointsDownload *)paramOperation
         changeProgress:(double)paramProgress
{
    if ([urlOne isEqualToString:paramOperation.url]) {
        _progressViewOne.progress = paramProgress;
        [_labelOne setText:[NSString stringWithFormat:@"%.1f%%", paramProgress * 100]];
    }else if([urlTwo isEqualToString:paramOperation.url]){
        _progressViewTwo.progress = paramProgress;
        [_labelTwo setText:[NSString stringWithFormat:@"%.1f%%", paramProgress * 100]];
    }
}

- (void)downloadManagerDidComplete:(SIDownloadManager *)siDownloadManager
                     withOperation:(SIBreakpointsDownload *)paramOperation
{
    if ([paramOperation.url isEqualToString:urlOne]) {
        NSLog(@"done one");
    }else if([paramOperation.url isEqualToString:urlTwo]){
        NSLog(@"done two");
    }
    
}

- (void)downloadManagerError:(SIDownloadManager *)siDownloadManager
                     withURL:(NSString *)paramURL 
                   withError:(NSError *)paramError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                        message:@"请检查你的网络连接状态！" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"取消" 
                                              otherButtonTitles:@"确认",nil];
    [alertView show];
      
}

- (void)downloadManagerDownloadDone:(SIDownloadManager *)siDownloadmanager
                            withURL:(NSString *)paramURL
{
    NSLog(@"done");
}

- (void)downloadManagerPauseTask:(SIDownloadManager *)siDownloadManager
                         withURL:(NSString *)paramURL
{
    
}

- (void)downloadManagerDownloadExist:(SIDownloadManager *)siDwonloadManager
                             withURL:(NSString *)paramURL
{
    
}

#pragma mark - others 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
