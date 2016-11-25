//
//  SVMemberReservationCell.m
//  iPhoneVideo
//
//  Created by ZK on 2016/10/31.
//  Copyright © 2016年 SOHU. All rights reserved.
//

#import "SVMemberReservationCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface SVMemberReservationCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *numberLabel;
@property(nonatomic, strong) UIImageView *lineImageView;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIImageView *tipBackgroundView;

@property(nonatomic, strong) NSMutableDictionary *dic;

@property(nonatomic, assign) NSInteger columnID;
@property(nonatomic, assign) NSInteger indexPath;

@property(nonatomic, strong) UILabel *badgeLabel;
@property(nonatomic, strong) UIImageView *badgeLabelBackView;

@end


@implementation SVMemberReservationCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addImageView];
        [self addTitleLabel];
        [self addNumberLabel];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];
        
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView).offset(5);
            make.bottom.equalTo(self.imageView).offset(-5);
            make.height.mas_equalTo(13);
        }];
        
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
            make.centerY.equalTo(self.titleLabel);
            make.height.mas_equalTo(13);
        }];

    }
    
    return self;
}

- (void)updateWithdataDic:(PlayerModel *)playerModel  indexPath:(NSInteger)indexPath
{
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:playerModel.portrait]];
    
    self.titleLabel.text = playerModel.name;
    self.numberLabel.text = [NSString stringWithFormat:@"%d在看",playerModel.online_users] ;
    
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width+1);
    }];

}



- (void)addTitleLabel {
    UILabel *titleLabel = [UILabel new];
    titleLabel.font =  [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel = titleLabel;
    [self.imageView addSubview:titleLabel];
}

- (void)addNumberLabel {
    UILabel *numberLabel = [UILabel new];
    numberLabel.font =  [UIFont systemFontOfSize:13];
    numberLabel.textColor = [UIColor whiteColor];
    self.numberLabel = numberLabel;
    [self.imageView addSubview:numberLabel];
}


- (void)addImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.userInteractionEnabled = YES;
    self.imageView = imageView;
    [self addSubview:imageView];
    
}


@end
