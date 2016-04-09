//
//  DACategory+CoreDataProperties.h
//  
//
//  Created by Elena on 07.04.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DACategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface DACategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *catpath;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *has_subcategory;

@end

NS_ASSUME_NONNULL_END
