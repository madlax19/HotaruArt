//
//  AppDelegate.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "AppDelegate.h"
#import "DeviantArtApiHelper.h"
#import <MagicalRecord/MagicalRecord.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import "LoginViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"HotaruArtModel"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.102 green:0.063 blue:0.204 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    [[DeviantArtApiHelper sharedHelper] checkAuthTokenWithSuccess:^{
        [[DeviantArtApiHelper sharedHelper] getDeviantUserInfo:^{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SWRevealViewController *revealController = [storyBoard instantiateViewControllerWithIdentifier:@"MainScreen"];
            revealController.rearViewRevealWidth = self.window.bounds.size.width * 0.66;
            self.window.rootViewController = revealController;
        } failure:^{

        }];
    } failure:^{
        NSLog(@"Not valid access token");
    }];
    
    
    return YES;
}

- (void)showLoginScreen {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.window.rootViewController = loginViewController;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [[DeviantArtApiHelper sharedHelper] handeOpenURL:url];
}


@end
