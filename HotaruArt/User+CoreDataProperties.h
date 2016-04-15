//
//  User+CoreDataProperties.h
//  
//
//  Created by Elena on 28.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *is_watching;
@property (nullable, nonatomic, retain) NSNumber *isCurrentUser;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *usericon;
@property (nullable, nonatomic, retain) NSString *userID;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *coverPhoto;
@property (nullable, nonatomic, retain) NSNumber *watchersCount;
@property (nullable, nonatomic, retain) NSNumber *friendsCount;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;
@property (nullable, nonatomic, retain) NSSet<DeviationObject *> *deviations;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

- (void)addDeviationsObject:(DeviationObject *)value;
- (void)removeDeviationsObject:(DeviationObject *)value;
- (void)addDeviations:(NSSet<DeviationObject *> *)values;
- (void)removeDeviations:(NSSet<DeviationObject *> *)values;

@end

NS_ASSUME_NONNULL_END
