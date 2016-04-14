//
//  ViewController.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "LoginViewController.h"
#import "DeviantArtApiHelper.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import "AppDelegate.h"
#import "WebViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (IBAction)loginButtonTouch:(id)sender {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    [[DeviantArtApiHelper sharedHelper] loginWithCompletionHandler:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeClear];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"Logined success!" maskType:SVProgressHUDMaskTypeClear];
            SWRevealViewController *revealController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainScreen"];
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            appDelegate.window.rootViewController = revealController;
        }
        [webViewController dismissViewControllerAnimated:YES completion:nil];
    }];
   [self showViewController:webViewController sender:nil];
}

@end
