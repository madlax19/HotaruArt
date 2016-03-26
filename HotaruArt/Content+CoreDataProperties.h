//
//  Content+CoreDataProperties.h
//  
//
//  Created by Elena on 23.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Content.h"

NS_ASSUME_NONNULL_BEGIN

@interface Content (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *filesize;
@property (nullable, nonatomic, retain) DeviationObject *deviationObject;

@end

NS_ASSUME_NONNULL_END
