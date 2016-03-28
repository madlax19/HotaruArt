//
//  ProfileViewController.m
//  HotaruArt
//
//  Created by Elena on 28.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "ProfileViewController.h"
#import "FeedCollectionViewCell.h"
#import "SWRevealViewController.h"
#import <CoreData/CoreData.h>
#import "DeviationObject.h"
#import <MagicalRecord/MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DeviantArtApiHelper.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ProfileViewController ()<NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;

@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *blockOperations;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blockOperations = [NSMutableArray new];
    float width = (self.collectionView.frame.size.width - 8) / 2;
    self.collectionViewLayout.itemSize = CGSizeMake(width, width);
    self.collectionViewLayout.minimumInteritemSpacing = 8;
    self.collectionViewLayout.minimumLineSpacing = 8;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUI];
    [SVProgressHUD show];
    [[DeviantArtApiHelper sharedHelper] getUser:self.user.username success:^(User *user) {
        self.user = user;
        [self updateUI];
        [[DeviantArtApiHelper sharedHelper] getUserDeviations:self.user.username success:^{
            [SVProgressHUD showSuccessWithStatus:@""];
        } failure:^{
            [SVProgressHUD showErrorWithStatus:@""];
        }];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@""];
    }];
    
}

- (void)updateUI {
    self.userNameLabel.text = self.user.username;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.usericon]];
    [self.followingButton setTitle:[NSString stringWithFormat:@"Following %@", self.user.friendsCount] forState:UIControlStateNormal];
    [self.followersButton setTitle:[NSString stringWithFormat:@"Followers %@", self.user.watchersCount] forState:UIControlStateNormal];
}

- (IBAction)followersButtonTouch:(id)sender {
}

- (IBAction)followingButtonTouch:(id)sender {
}

- (IBAction)commentsButtonTouch:(id)sender {
}

- (void)clearOperationQuery{
    for (NSBlockOperation *operation in self.blockOperations) {
        [operation cancel];
    }
    [self.blockOperations removeAllObjects];
}

- (NSFetchedResultsController*)fetchedResultsController {
    if (!_fetchedResultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[DeviationObject MR_entityName]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviationObjectID" ascending:true]];
        request.predicate = [NSPredicate predicateWithFormat:@"author.userID = %@", self.user.userID];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
        controller.delegate = self;
        _fetchedResultsController = controller;
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    FeedCollectionViewCell *feedCell = (FeedCollectionViewCell*)cell;
    DeviationObject *devObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    [feedCell.imageView sd_setImageWithURL:[NSURL URLWithString:devObject.thumbs.allObjects.firstObject.src]];
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    DeviationObject *devObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
//    DetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
//    viewController.deviationObject = devObject;
//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self clearOperationQuery];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (type == NSFetchedResultsChangeUpdate) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }];
        [self.blockOperations addObject:operation];
    } else if (type == NSFetchedResultsChangeInsert) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }];
        [self.blockOperations addObject:operation];
        
    } else if (type == NSFetchedResultsChangeDelete) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }];
        [self.blockOperations addObject:operation];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeUpdate) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
        [self.blockOperations addObject:operation];
    } else if (type == NSFetchedResultsChangeInsert) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        }];
        [self.blockOperations addObject:operation];
        
    } else if (type == NSFetchedResultsChangeMove) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
        }];
        [self.blockOperations addObject:operation];
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
        [self.blockOperations addObject:operation];
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSBlockOperation *operation in self.blockOperations) {
            [operation start];
        }
    } completion:^(BOOL finished) {
        [self.blockOperations removeAllObjects];
    }];
}


@end
