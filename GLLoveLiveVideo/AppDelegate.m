//
//  AppDelegate.m
//  GLLoveLiveVideo
//
//  Created by ZK on 2016/10/21.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "AppDelegate.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import "MainTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
//    //设置log等级，此处log为默认在app沙盒目录下的msc.log文件
//    [IFlySetting setLogFile:LVL_ALL];
//    
//    //输出在console的log开关
//    [IFlySetting showLogcat:YES];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = [paths objectAtIndex:0];
//    //设置msc.log的保存路径
//    [IFlySetting setLogFilePath:cachePath];
//    
//    //创建语音配置,appid必须要传入，仅执行一次则可
//    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,",@"58008ab6"];
//    
//    //所有服务启动前，需要确保执行createUtility
//    [IFlySpeechUtility createUtility:initString];
//    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor =[UIColor whiteColor];
    
    MainTabBarController *tabBarVC = [[MainTabBarController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarVC;
    
    self.window.rootViewController = tabBarVC;
    
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
