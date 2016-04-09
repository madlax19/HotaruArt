//
//  MenuViewController.m
//  HotaruArt
//
//  Created by Elena on 20.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "MenuViewController.h"

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *deviationsSearchBar;
@property (nonatomic, strong) NSArray *menuItems;
@property NSInteger currentRow;

@end

@implementation MenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.menuItems = @[
                           [MenuItem itemWithTitle:@"Newest" action:^{
                               NSLog(@"Newest");
                           }],
                           [MenuItem itemWithTitle:@"Popular" action:^{
                               NSLog(@"Popular");
                           }],
                           [MenuItem itemWithTitle:@"Hot" action:^{
                               NSLog(@"Hot");
                           }],
                           [MenuItem itemWithTitle:@"Sign Out" action:^{
                               NSLog(@"Sign Out");
                           }]
                       ];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - TableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    tableCell.textLabel.text = item.title;
    return tableCell;
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    if (self.deviationsSearchBar.text.length > 0) {
        [self sendSearchRequest:self.deviationsSearchBar.text];
    }
}

- (void)sendSearchRequest:(NSString*)searchText{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    item.action();
    if (indexPath.row == 3) {
        //sign out
    } else {
        self.currentRow = indexPath.row;
    }
}

@end
