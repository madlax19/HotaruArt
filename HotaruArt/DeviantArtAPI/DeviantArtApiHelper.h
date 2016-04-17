//
//  DeviantArtApiHelper.h
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface DeviantArtApiHelper : NSObject

@property (nonatomic, strong) NSString *accessToken;

+ (id)sharedHelper;
- (BOOL)handeOpenURL:(NSURL*) url;
- (void)checkAuthTokenWithSuccess:(void(^)())success failure:(void(^)())failure;
- (void)loginWithCompletionHandler:(void(^)(NSError* error))completionHandler;
- (void)getDeviantUserInfo:(void(^)())success failure:(void(^)())failure;
- (void)browseNewest:(NSString*)searchText success:(void(^)())success failure:(void(^)())failure;
- (void)getCommentForDeviationID:(NSString*)deviationID success:(void(^)())success failure:(void(^)())failure;
- (void)getUserDeviations:(NSString*)userName success:(void(^)())success failure:(void(^)())failure;
- (void)getUser:(NSString*)userName success:(void(^)(User*))success failure:(void(^)())failure;
- (void)browseHot:(void(^)())success failure:(void(^)())failure;
- (void)browsePopular:(NSString*)searchText success:(void (^)())success failure:(void (^)())failure;
- (User*)currentUser;

@end
