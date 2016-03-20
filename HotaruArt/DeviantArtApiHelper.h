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
+ (id)sharedHelper;
- (BOOL)handeOpenURL:(NSURL*) url;
- (void)loginWithCompletionHandler:(void(^)(NSError* error))completionHandler;

@end
