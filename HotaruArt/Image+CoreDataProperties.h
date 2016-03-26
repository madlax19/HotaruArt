//
//  Image+CoreDataProperties.h
//  
//
//  Created by Elena on 23.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Image.h"

NS_ASSUME_NONNULL_BEGIN

@interface Image (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSString *src;
@property (nullable, nonatomic, retain) NSNumber *transparency;
@property (nullable, nonatomic, retain) NSNumber *width;

@end

NS_ASSUME_NONNULL_END
