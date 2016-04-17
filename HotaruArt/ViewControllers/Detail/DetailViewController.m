//
//  DetailViewController.m
//  HotaruArt
//
//  Created by Elena on 27.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "DetailViewController.h"
#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DeviantArtApiHelper.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "Comment.h"
#import "DeviationTableViewCell.h"
#import "CommentTableViewCell.h"
#import "Image.h"
#import "ProfileViewController.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 328;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [[DeviantArtApiHelper sharedHelper] getCommentForDeviationID:self.deviationObject.deviationObjectID success:^{
        [SVProgressHUD showSuccessWithStatus:@""];
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@""];
    }];
}

- (NSFetchedResultsController*)fetchedResultsController {
    if (!_fetchedResultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Comment MR_entityName]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"commentID" ascending:true]];
        request.predicate = [NSPredicate predicateWithFormat:@"deviationID = %@", self.deviationObject.deviationObjectID];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController = controller;
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showUserProfile"]) {
        ProfileViewController *profileViewController = segue.destinationViewController;
        profileViewController.user = self.deviationObject.author;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 328.0 : UITableViewAutomaticDimension;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = nil;
    if (indexPath.row == 0) {
        identifier = @"DeviationTableViewCell";
    } else {
        identifier = @"CommentTableViewCell";
    }
    return [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        Image *image = self.deviationObject.preview != nil ? self.deviationObject.preview : self.deviationObject.content;
        DeviationTableViewCell* deviationCell = (DeviationTableViewCell *)cell;
        [deviationCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.deviationObject.author.usericon]];
        
        deviationCell.avatarImageView.layer.masksToBounds = YES;
        deviationCell.avatarImageView.layer.cornerRadius = deviationCell.avatarImageView.bounds.size.height / 2;
        
        [deviationCell.deviationImageView sd_setImageWithURL:[NSURL URLWithString:image.src] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                deviationCell.deviationImageView.image = [UIImage imageNamed:@"image_placeholder"];
            }
        }];
        deviationCell.userNameLabel.text = self.deviationObject.author.username;
        deviationCell.onUserTitleTouch = ^{
            [self performSegueWithIdentifier:@"showUserProfile" sender:nil];
        };
    } else {
        CommentTableViewCell *commentCell = (CommentTableViewCell *)cell;
        Comment *comment = self.fetchedResultsController.fetchedObjects[indexPath.row - 1];
        [commentCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.user.usericon]];
        
        commentCell.avatarImageView.layer.masksToBounds = YES;
        commentCell.avatarImageView.layer.cornerRadius = commentCell.avatarImageView.bounds.size.height / 2;
        
        commentCell.userNameLabel.text = comment.user.username;
        commentCell.commentLabel.attributedText = [[NSAttributedString alloc]initWithString:comment.body];
    }
}

@end
