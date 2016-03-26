//
//  Preview+CoreDataProperties.h
//  
//
//  Created by Elena on 23.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Preview.h"

NS_ASSUME_NONNULL_BEGIN

@interface Preview (CoreDataProperties)

@property (nullable, nonatomic, retain) DeviationObject *deviationObject;

@end

NS_ASSUME_NONNULL_END
