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

@interface DetailViewController () <UITableViewDataSource, NSFetchedResultsControllerDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *blockOperations;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [[DeviantArtApiHelper sharedHelper] getCommentForDeviationID:self.deviationObject.deviationObjectID success:^{
        [SVProgressHUD showSuccessWithStatus:@""];
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
        controller.delegate = self;
        _fetchedResultsController = controller;
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

- (void)clearOperationQuery{
    for (NSBlockOperation *operation in self.blockOperations) {
        [operation cancel];
    }
    [self.blockOperations removeAllObjects];
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
    return indexPath.row == 0 ? 328.0 : 44.0;
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
        NSLog(@"%@", self.deviationObject.content);
        Image *image = self.deviationObject.preview != nil ? self.deviationObject.preview : self.deviationObject.content;
        DeviationTableViewCell* deviationCell = (DeviationTableViewCell *)cell;
        [deviationCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.deviationObject.author.usericon]];
        [deviationCell.deviationImageView sd_setImageWithURL:[NSURL URLWithString:image.src]];
        deviationCell.userNameLabel.text = self.deviationObject.author.username;
        deviationCell.onUserTitleTouch = ^{
            [self performSegueWithIdentifier:@"showUserProfile" sender:nil];
        };
    } else {
        CommentTableViewCell *commentCell = (CommentTableViewCell *)cell;
        Comment *comment = self.fetchedResultsController.fetchedObjects[indexPath.row - 1];
        [commentCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.user.usericon]];
        commentCell.userNameLabel.text = comment.user.username;
        commentCell.commentLabel.text = comment.body;
    }
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self clearOperationQuery];
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (type == NSFetchedResultsChangeUpdate) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.blockOperations addObject:operation];
    } else if (type == NSFetchedResultsChangeInsert) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.blockOperations addObject:operation];
        
    } else if (type == NSFetchedResultsChangeDelete) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.blockOperations addObject:operation];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeUpdate) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.blockOperations addObject:operation];
    } else if (type == NSFetchedResultsChangeInsert) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.blockOperations addObject:operation];
        
    } else if (type == NSFetchedResultsChangeMove) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        }];
        [self.blockOperations addObject:operation];
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.blockOperations addObject:operation];
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    for (NSBlockOperation *operation in self.blockOperations) {
        [operation start];
    }
    [self.tableView endUpdates];
    [self.blockOperations removeAllObjects];
}


@end
