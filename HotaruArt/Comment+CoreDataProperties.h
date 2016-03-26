//
//  Comment+CoreDataProperties.h
//  
//
//  Created by Elena on 23.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentID;
@property (nullable, nonatomic, retain) NSString *parentID;
@property (nullable, nonatomic, retain) NSString *posted;
@property (nullable, nonatomic, retain) NSNumber *replies;
@property (nullable, nonatomic, retain) NSString *hidden;
@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
