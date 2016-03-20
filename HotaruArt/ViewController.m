//
//  ViewController.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "ViewController.h"
#import "DeviantArtApiHelper.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)loginButtonTouch:(id)sender {
    [[DeviantArtApiHelper sharedHelper] loginWithCompletionHandler:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeClear];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"Logined success!" maskType:SVProgressHUDMaskTypeClear];
        }
    }];
}

@end
