//
//  MenuViewController.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "DeviantArtApiHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "SearchViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "SearchDeviation.h"

@interface MenuItem : NSObject

+ (instancetype)itemWithTitle:(NSString*)title action:(void(^)())action;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void(^action)();

@end

@implementation MenuItem;

+ (instancetype)itemWithTitle:(NSString *)title action:(void (^)())action {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.action = action;
    return item;
}

@end


@interface MenuViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *deviationsSearchBar;
@property (nonatomic, strong) NSArray *menuItems;
@property NSInteger currentRow;

@end

@implementation MenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.menuItems = @[
                           [MenuItem itemWithTitle:@"Newest" action:^{
                               [self.deviationsSearchBar setUserInteractionEnabled:YES];
                               [self performSegueWithIdentifier:@"showNewest" sender:nil];
                           }],
                           [MenuItem itemWithTitle:@"Popular" action:^{
                               [self.deviationsSearchBar setUserInteractionEnabled:YES];
                               [self performSegueWithIdentifier:@"showPopular" sender:nil];
                           }],
                           [MenuItem itemWithTitle:@"Hot" action:^{
                               [self.deviationsSearchBar setUserInteractionEnabled:NO];
                               [self performSegueWithIdentifier:@"showHot" sender:nil];
                           }],
                           [MenuItem itemWithTitle:@"Sign Out" action:^{
                               [self.deviationsSearchBar setUserInteractionEnabled:YES];
                               DeviantArtApiHelper *helper = [DeviantArtApiHelper sharedHelper];
                               helper.accessToken = nil;
                               AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                               [appDelegate showLoginScreen];
                           }]
                       ];
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height / 2;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.deviationsSearchBar.text = nil;
    DeviantArtApiHelper *helper = [DeviantArtApiHelper sharedHelper];
    User *user = [helper currentUser];
    self.userNameLabel.text = user.username;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.usericon]];
}

#pragma mark - TableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    tableCell.textLabel.text = item.title;
    return tableCell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.deviationsSearchBar.text.length > 0) {
        [self sendSearchRequest:self.deviationsSearchBar.text];
    }
}

- (void)sendSearchRequest:(NSString*)searchText {

    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSArray *all = [SearchDeviation MR_findAll];
    for (SearchDeviation *object in all) {
        [context deleteObject:object];
    }
    
    if (self.currentRow == 0) {
        [SVProgressHUD show];
        [[DeviantArtApiHelper sharedHelper]browseNewest:searchText success:^{
            [SVProgressHUD showSuccessWithStatus:@""];
            SearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
                [(UINavigationController*)self.revealViewController.frontViewController pushViewController:searchVC animated:YES];
            [self.revealViewController revealToggleAnimated:YES];
        } failure:^{
            [SVProgressHUD showErrorWithStatus:@""];
        }];
    } else if (self.currentRow == 1) {
        [SVProgressHUD show];
        [[DeviantArtApiHelper sharedHelper]browsePopular:searchText success:^{
            [SVProgressHUD showSuccessWithStatus:@""];
            SearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
            [(UINavigationController*)self.revealViewController.frontViewController pushViewController:searchVC animated:YES];
            [self.revealViewController revealToggleAnimated:YES];
        } failure:^{
            [SVProgressHUD showErrorWithStatus:@""];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    item.action();
    [self.revealViewController revealToggleAnimated:YES];
    if (indexPath.row != 3) {
        self.currentRow = indexPath.row;
    }
}

@end
