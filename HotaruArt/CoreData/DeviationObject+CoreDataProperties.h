//
//  DeviationObject+CoreDataProperties.h
//  
//
//  Created by Elena on 23.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DeviationObject.h"
#import "Content.h"
#import "Thumb.h"
#import "User.h"
#import "Preview.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviationObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSString *deviationObjectID;
@property (nullable, nonatomic, retain) NSNumber *is_favourited;
@property (nullable, nonatomic, retain) NSString *printid;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Content *content;
@property (nullable, nonatomic, retain) NSSet<Thumb *> *thumbs;
@property (nullable, nonatomic, retain) User *author;
@property (nullable, nonatomic, retain) Preview *preview;

@end

@interface DeviationObject (CoreDataGeneratedAccessors)

- (void)addThumbsObject:(Thumb *)value;
- (void)removeThumbsObject:(Thumb *)value;
- (void)addThumbs:(NSSet<Thumb *> *)values;
- (void)removeThumbs:(NSSet<Thumb *> *)values;

@end

NS_ASSUME_NONNULL_END
