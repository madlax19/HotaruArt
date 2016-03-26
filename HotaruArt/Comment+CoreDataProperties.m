//
//  Comment+CoreDataProperties.m
//  
//
//  Created by Elena on 23.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment+CoreDataProperties.h"

@implementation Comment (CoreDataProperties)

@dynamic commentID;
@dynamic parentID;
@dynamic posted;
@dynamic replies;
@dynamic hidden;
@dynamic body;
@dynamic user;

@end
