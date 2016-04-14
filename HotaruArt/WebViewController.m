//
//  WebViewController.m
//  HotaruArt
//
//  Created by Elena on 14.04.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     NSString *urlString = @"https://www.deviantart.com/oauth2/authorize?scope=browse&redirect_uri=hotaruart://4281&response_type=code&client_id=4281";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (IBAction)cancelButtonTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
