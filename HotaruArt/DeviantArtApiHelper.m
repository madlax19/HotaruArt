//
//  DeviantArtApiHelper.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "DeviantArtApiHelper.h"


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

- (void)loginWithCompletionHandler:(void(^)(NSError* error))completionHandler{
    self.completionHandler = completionHandler;
    NSString *url = @"https://www.deviantart.com/oauth2/authorize?scope=browse&redirect_uri=hotaruart://4281&response_type=code&client_id=4281";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)callCompletionHandlerWithError:(NSError*) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionHandler(error);
    });
}

@end
