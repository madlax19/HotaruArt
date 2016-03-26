//
//  DeviantArtApiHelper.h
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviantArtApiHelper : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userIcon;
@property (nonatomic, strong) NSString *type;

+ (id)sharedHelper;
- (BOOL)handeOpenURL:(NSURL*) url;
- (void)loginWithCompletionHandler:(void(^)(NSError* error))completionHandler;
- (void)getDeviantUserInfo:(void(^)())success failure:(void(^)())failure;
- (void)browseNewest:(void(^)())success failure:(void(^)())failure;

@end
