//
//  Recode+CoreDataProperties.h
//  m2048
//
//  Created by Yanping Lan on 1/9/16.
//  Copyright © 2016 Danqing. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Recode.h"

NS_ASSUME_NONNULL_BEGIN

@interface Recode (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSString *score;
@property (nullable, nonatomic, retain) NSDate *recodeTime;

@end

NS_ASSUME_NONNULL_END
