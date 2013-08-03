//
//  GoodCell.h
//  DoGood
//
//  Created by Michael on 2013-08-03.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodCell : UITableViewCell {
    
    __weak IBOutlet UILabel *username;
}

@property (nonatomic, weak) UILabel *username;

@end
