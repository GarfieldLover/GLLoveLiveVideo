//
//  CameraViewController.m
//   
//
//  Created by ZK on 16/7/3.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "CameraViewController.h"
#import "StartLiveView.h"
//#import "GPUImageGaussianBlurFilter.h"

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextField *myTitle;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"开播";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //设置背景图片高斯模糊
    [self gaussianImage];

}


#pragma mark ---- <设置背景图片高斯模糊>
- (void)gaussianImage {
    
    UIImage * image = [UIImage imageNamed:@"bg_zbfx"];
    
    self.backgroundView.image = image;
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.backgroundView.bounds;
    [self.backgroundView addSubview:visualEffectView];
}

//返回主界面
- (IBAction)backMain {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//开始直播采集
- (IBAction)startLiveStream {
    
    StartLiveView *view = [[StartLiveView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    
    _backBtn.hidden = YES;
    _middleView.hidden = YES;
    
    [_myTitle resignFirstResponder];
    
}

@end
