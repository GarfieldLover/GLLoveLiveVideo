
#import "MainTabBarController.h"
#import "MainNavigationController.h"
#import "CameraViewController.h"
#import "LiveViewController.h"
#import "MineViewController.h"
#import "CameraViewController.h"
#import "UIImage+Image.h"
#import "UIView+Frame.h"



//重复点击tabBar上按钮，刷新当前界面
NSString * const repeateClickTabBarButtonNote = @"repeateClickTabBarButton";
@interface MainTabBarController () <UITabBarControllerDelegate>

@property (nonatomic,weak) UIViewController *lastViewController;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加所有的子控制器
    [self setupAllViewController];
    
    // 设置tabBar上按钮的内容
    [self setupAllTabBarButton];
    
    // 添加视频采集按钮
    [self addCameraButton];

    // 设置代理 监听tabBar上按钮点击
    self.delegate = self;
    
    _lastViewController = self.childViewControllers.firstObject;
    
}

#pragma mark ---- <添加视频采集按钮>
- (void)addCameraButton {
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cameraBtn setImage:[UIImage imageNamed:@"tab_room"] forState:UIControlStateNormal];
    [cameraBtn setImage:[UIImage imageNamed:@"tab_room_p"] forState:UIControlStateHighlighted];
    
    // 自适应,自动根据按钮图片和文字计算按钮尺寸
    [cameraBtn sizeToFit];
    
    cameraBtn.center = CGPointMake(self.tabBar.xj_width * 0.5, self.tabBar.xj_height * 0.5 + 5);
    [cameraBtn addTarget:self action:@selector(clickCameraBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:cameraBtn];
    
}

#pragma mark ---- <点击了CameraBtn>
- (void)clickCameraBtn {
    
    CameraViewController *cameraVc = [[CameraViewController alloc] init];
    [self presentViewController:cameraVc animated:YES completion:nil];
    
}


#pragma mark ---- <UITabBarControllerDelegate>
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    if (_lastViewController == viewController) {
//        NSLog(@"重复点击");
        
        // 发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:repeateClickTabBarButtonNote object:nil];
        // 通知对应的子控制器去刷新界面
        
        }
    _lastViewController = viewController;
    
}

#pragma mark ---- <设置tabBar上按钮的内容>
- (void)setupAllTabBarButton {
    
    //设置TabBar按钮的内容
    LiveViewController *liveVc = self.childViewControllers[0];
    liveVc.tabBarItem.image = [UIImage imageNamed:@"tab_live"];
    liveVc.tabBarItem.selectedImage = [UIImage imageWithOriginalRenderingMode:@"tab_live_p"];
    liveVc.tabBarItem.title = @"千帆";

    CameraViewController *cameraVc = self.childViewControllers[1];
    cameraVc.tabBarItem.image = [UIImage imageNamed:@"tab_room"];
    cameraVc.tabBarItem.selectedImage = [UIImage imageWithOriginalRenderingMode:@"tab_room_p"];
    cameraVc.tabBarItem.title = @"开播";

    MineViewController *mineVc = self.childViewControllers[2];
    mineVc.tabBarItem.image = [UIImage imageNamed:@"tab_me"];
    mineVc.tabBarItem.selectedImage = [UIImage imageWithOriginalRenderingMode:@"tab_me_p"];
    mineVc.tabBarItem.title = @"看播";

}

#pragma mark ---- <添加所有的子控制>
- (void)setupAllViewController {
    
    //Live
    LiveViewController *liveVc = [[LiveViewController alloc] init];
    MainNavigationController *liveNav = [[MainNavigationController alloc] initWithRootViewController:liveVc];
    
    [self addChildViewController:liveNav];
    
    //Camera
    CameraViewController *cameraVc = [[CameraViewController alloc] init];
    MainNavigationController *cameraNav = [[MainNavigationController alloc] initWithRootViewController:cameraVc];
    
    [self addChildViewController:cameraNav];
    
    //Main
    MineViewController *mineVc = [[MineViewController alloc] init];
    MainNavigationController *mineNav = [[MainNavigationController alloc] initWithRootViewController:mineVc];
    
    [self addChildViewController:mineNav];
    
}

@end
