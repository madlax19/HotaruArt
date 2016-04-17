//
//  DeviationTableViewCell.m
//  HotaruArt
//
//  Created by Elena on 27.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "DeviationTableViewCell.h"

@implementation DeviationTableViewCell

- (IBAction)userNameTouch:(id)sender {
    if (self.onUserTitleTouch) {
        self.onUserTitleTouch();
    }
}


@end
