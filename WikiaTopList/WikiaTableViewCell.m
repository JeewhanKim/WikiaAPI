//
//  WikiaTableViewCell.m
//  WikiaTopList
//
//  Created by Jeewhan on 4/20/15.
//  Copyright (c) 2015 MichaelKim. All rights reserved.
//

#import "WikiaTableViewCell.h"

@implementation WikiaTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.wikiTitle = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 140, 30)];
        self.wikiTitle.textColor = [UIColor whiteColor];
        self.wikiTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        
        [self addSubview:self.wikiTitle];
        
        self.wikiUrl = [[UILabel alloc] initWithFrame:CGRectMake(170, 19, 140, 30)];
        self.wikiUrl.textColor = [UIColor yellowColor];
        self.wikiUrl.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        
        [self addSubview:self.wikiUrl];

        self.wikiImage = [[UIImageView alloc] initWithFrame:CGRectMake(17, 10, 138, 36)];

        [self addSubview:self.wikiImage];
    }
    return self;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
