//
//  CommentTableViewCell.h
//  HotaruArt
//
//  Created by Elena on 27.03.16.
//  Copyright © 2016 Elena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
