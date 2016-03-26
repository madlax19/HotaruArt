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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"HotaruArtModel"];
    //show_spinner
    [[DeviantArtApiHelper sharedHelper] getDeviantUserInfo:^{
        //show_spinner_succes("Some Text")
        NSLog(@"Ne jopka");
    } failure:^{
        //show_spiner_Error("Some text");
        NSLog(@"Jopka");
    }];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [[DeviantArtApiHelper sharedHelper] handeOpenURL:url];
}


@end
