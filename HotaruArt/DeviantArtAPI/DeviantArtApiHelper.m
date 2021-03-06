//
//  DeviantArtApiHelper.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "DeviantArtApiHelper.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DeviationObject.h"
#import "NewestDeviation.h"
#import "PopularDeviation.h"
#import "HotDeviation.h"
#import "Comment.h"
#import "DACategory.h"
#import "SearchDeviation.h"
#import <Lockbox/Lockbox.h>

@interface DeviantArtApiHelper()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) void (^completionHandler)(NSError *error);
@end



@implementation DeviantArtApiHelper

+ (id)sharedHelper {
    static DeviantArtApiHelper *helper = nil;
    @synchronized(self) {
        if (helper == nil) {
            helper = [[self alloc] init];
        }
    }
    return helper;
}

- (id)init{
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 4;
        self.session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (NSString*)valueForKey:(NSString*)key fromQueryItems:(NSArray*)queryItems {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

- (BOOL)handeOpenURL:(NSURL*) url{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    NSString *code = [self valueForKey:@"code" fromQueryItems: queryItems];
    
    if (code) {
        [self getDeviantArtAuthTokenWithCode:code];
        return YES;
    }
    [self callCompletionHandlerWithError:[NSError errorWithDomain:@"hotaruArt" code:500 userInfo:nil]];
    return NO;
}

- (void)getDeviantArtAuthTokenWithCode:(NSString*)code{
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/oauth2/token?client_id=4281&client_secret=959d2dee177e3827884a0746d7431538&grant_type=authorization_code&code=%@&redirect_uri=hotaruart://4281", code];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
           [self callCompletionHandlerWithError:error];
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                [self callCompletionHandlerWithError:jsonError];
            } else {
                NSString *token = [jsonData objectForKey:@"access_token"];
                if (token) {
                    self.accessToken = token;
                    [self callCompletionHandlerWithError:nil];
                }
            }
        }
    }];
    [task resume];
}

- (void)setAccessToken:(NSString *)accessToken {
    [Lockbox archiveObject:accessToken forKey:@"accessTocken"];
}

- (NSString*)accessToken {
    return [Lockbox unarchiveObjectForKey:@"accessTocken"];
}

- (void)getDeviantUserInfo:(void(^)())success failure:(void(^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/user/whoami?token=%@", self.accessToken];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    User *user = [User MR_importFromObject:jsonData inContext:[NSManagedObjectContext MR_defaultContext]];
                    user.isCurrentUser = [NSNumber numberWithBool:YES];
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                }];
            }
        }
    }];
    [task resume];

}

- (User*)currentUser {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrentUser=true"];
    return [User MR_findFirstWithPredicate:predicate];
}

- (void)getUser:(NSString*)userName success:(void(^)(User*))success failure:(void(^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/user/profile/%@?token=%@", userName, self.accessToken];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                failure();
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSMutableDictionary *userDictionary = [NSMutableDictionary dictionaryWithDictionary:[jsonData objectForKey:@"user"]];
                NSDictionary *stats = [jsonData objectForKey:@"stats"];
                if (stats) {
                    [userDictionary setObject:stats forKey:@"stats"];
                }
                if (userDictionary) {
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                        User *user = [User MR_importFromObject:userDictionary inContext:[NSManagedObjectContext MR_defaultContext]];
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                success(user);
                            });
                        }

                    }];
                }
            }
        }
    }];
    [task resume];
    
}

- (void)browseNewest:(NSString*)searchText success:(void(^)())success failure:(void(^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/browse/newest?token=%@&limit=20", self.accessToken];
    if (searchText && searchText.length > 0) {
        url = [NSString stringWithFormat:@"%@&q=%@", url, searchText];
    }
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSArray *results = [jsonData objectForKey:@"results"];
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    if (searchText && searchText.length > 0) {
                        [SearchDeviation MR_importFromArray:results inContext:[NSManagedObjectContext MR_defaultContext]];
                    } else {
                        [NewestDeviation MR_importFromArray:results inContext:[NSManagedObjectContext MR_defaultContext]];
                    }
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                }];
            }
        }
    }];
    [task resume];
}

- (void)browseHot:(void(^)())success failure:(void(^)())failure{
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/browse/hot?token=%@&limit=20", self.accessToken];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSArray *results = [jsonData objectForKey:@"results"];
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    [HotDeviation MR_importFromArray:results inContext:[NSManagedObjectContext MR_defaultContext]];
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                }];
            }
        }
    }];
    [task resume];
}

- (void)browsePopular:(NSString*)searchText success:(void (^)())success failure:(void (^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/browse/popular?token=%@&limit=20", self.accessToken];
    if (searchText && searchText.length > 0) {
        url = [NSString stringWithFormat:@"%@&q=%@", url, searchText];
    }
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSArray *results = [jsonData objectForKey:@"results"];
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    if (searchText && searchText.length > 0) {
                        [SearchDeviation MR_importFromArray:results inContext:[NSManagedObjectContext MR_defaultContext]];
                    } else {
                        [PopularDeviation MR_importFromArray:results inContext:[NSManagedObjectContext MR_defaultContext]];
                    }
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                }];
            }
        }
    }];
    [task resume];
}

- (void)getUserDeviations:(NSString*)userName success:(void(^)())success failure:(void(^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/gallery/all?token=%@&username=%@", self.accessToken, userName];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSArray *results = [jsonData objectForKey:@"results"];
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    [DeviationObject MR_importFromArray:results inContext:[NSManagedObjectContext MR_defaultContext]];
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                }];
            }
        }
    }];
    [task resume];
}

- (void)getCommentForDeviationID:(NSString*)deviationID success:(void(^)())success failure:(void(^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/comments/deviation/%@?access_token=%@",deviationID,self.accessToken];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSArray *thread = [jsonData objectForKey:@"thread"];
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    NSArray<Comment*> *array = [Comment MR_importFromArray:thread inContext:[NSManagedObjectContext MR_defaultContext]];
                    for (Comment *comment in array) {
                        comment.deviationID = deviationID;
                    }
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                }];
            }
        }

    }];
    [task resume];
}

- (void)checkAuthTokenWithSuccess:(void(^)())success failure:(void(^)())failure {
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/placebo?token=%@", self.accessToken];
    NSURLSessionTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        void(^failureBlock)() = ^{
            if (failure) {
                self.accessToken = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                });
            }
        };
        if (error) {
            failureBlock();
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                failureBlock();
            } else {
                NSString *results = [jsonData objectForKey:@"status"];
                if ([results isEqualToString:@"success"]) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                } else {
                    failureBlock();
                }
            }
        }
    }];
    [task resume];
}


- (void)loginWithCompletionHandler:(void(^)(NSError* error))completionHandler{
    self.completionHandler = completionHandler;
//    NSString *url = @"https://www.deviantart.com/oauth2/authorize?scope=browse&redirect_uri=hotaruart://4281&response_type=code&client_id=4281";
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)callCompletionHandlerWithError:(NSError*) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionHandler(error);
    });
}

@end

