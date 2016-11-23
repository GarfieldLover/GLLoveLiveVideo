//
//  SVMemberReservationCell.m
//  iPhoneVideo
//
//  Created by ZK on 2016/10/31.
//  Copyright © 2016年 SOHU. All rights reserved.
//

#import "SVMemberReservationCell.h"
#import "SVColumnVideosRequestInfo.h"
#import "SVColumnsTableViewController.h"
#import "GradientTool.h"


@interface SVMemberReservationButton : UIButton

@end


@implementation SVMemberReservationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage* normalImage = [self normalImageSelected:NO];
        UIEdgeInsets edge={0,17,0,17};
        normalImage=[normalImage resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
        
        [self setBackgroundImage:normalImage forState:UIControlStateNormal];
        
        [self setTitle:@"立即预约" forState:UIControlStateNormal];
        self.titleLabel.font = UIFontV5_14;
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self setTitle:@"预约成功" forState:UIControlStateNormal];
        UIImage* normalImage = [self normalImageSelected:YES];
        UIEdgeInsets edge={0,17,0,17};
        normalImage=[normalImage resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
        
        [self setBackgroundImage:normalImage forState:UIControlStateNormal];
        
    } else {
        [self setTitle:@"立即预约" forState:UIControlStateNormal];
        UIImage* normalImage = [self normalImageSelected:NO];
        UIEdgeInsets edge={0,17,0,17};
        normalImage=[normalImage resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
        
        [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    }
}

- (UIImage *)normalImageSelected:(BOOL)isSelected {
    if (isSelected) {
        [self setTitleColor:UIColorV6_1A1A1A forState:UIControlStateNormal];
        return [UIImage imageNamed:@"Btn-GrayLine"];
    } else {
        [self setTitleColor:UIColorV6_FF382E forState:UIControlStateNormal];
        return [UIImage imageNamed:@"Btn-Redline"];
    }
}

@end

static CGFloat const BadgeWidth  = 27;
static CGFloat const BadgeHeight = 15;
static CGFloat const BadgeBottom =  0;

@interface SVMemberReservationCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIImageView *lineImageView;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) SVMemberReservationButton *button;
@property(nonatomic, strong) UIImageView *tipBackgroundView;

@property(nonatomic, strong) SVTemplate *templateInfo;
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
        [self addDateLabel];
        [self addLineImageView];
        [self addImageView];
        [self addTipBackgroundView];
        [self addTitleLabel];
        [self addButton];
        [self addBadgeLabel];

        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(13);
        }];
        
        [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.dateLabel.mas_bottom).offset(12);
            make.height.mas_equalTo(6);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lineImageView.mas_bottom).offset(12);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(105);
            make.height.mas_equalTo(105* (11.0/8.0));
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(8);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(38);
            make.centerX.equalTo(self);
        }];
        
        [self.tipBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.imageView);
            make.height.mas_equalTo(50);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView).offset(5);
            make.right.equalTo(self.imageView).offset(-5);
            make.bottom.equalTo(self.imageView).offset(-5);
            make.height.mas_equalTo(13);
        }];
        
        [self.badgeLabelBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imageView).with.offset(- BadgeBottom);
            make.width.mas_equalTo(BadgeWidth);
            make.top.equalTo(self.imageView).with.offset(BadgeBottom);
            make.height.mas_equalTo(BadgeHeight);
        }];
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imageView).with.offset(- BadgeBottom);
            make.width.mas_equalTo(BadgeWidth);
            make.top.equalTo(self.imageView).with.offset(BadgeBottom);
            make.height.mas_equalTo(BadgeHeight);
        }];
        
    }
    
    return self;
}

- (void)updateWithTemplate:(SVTemplate *)templateInfo dataDic:(NSDictionary *)dic columnID:(NSInteger)columnID indexPath:(NSInteger)indexPath
{
    self.columnID = columnID;
    self.indexPath = indexPath;
    
    self.templateInfo = templateInfo;
    if([dic isKindOfClass:[NSMutableDictionary class]]){
        self.dic = (NSMutableDictionary*)dic;
    }
    
    weakify(self);
    NSString* imageURL = [dic stringForKey:@"ver_high_pic"];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                      placeholderImage:[UIImage imageNamed:@"DefaultImage-HorVideo"]
                               options:SDWebImageRetryFailed
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 strongify(self);
                                 if (self && image && !error) {
                                     if(cacheType == SDImageCacheTypeNone){
                                         CATransition *transition = [CATransition animation];
                                         transition.type = kCATransitionFade;
                                         transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                         transition.duration = [UIView animationDuration];
                                         [self.imageView.layer addAnimation:transition forKey:nil];
                                     }
                                 }
                             }];
    
    self.dateLabel.text = [dic stringForKey:templateInfo.tipKey];
    self.titleLabel.text = [dic stringForKey:templateInfo.titleKey];
    
    BOOL feed = [dic boolForKey:@"feed"];
    self.button.selected = feed;
    
    self.badgeLabel.text = [dic stringForKey:templateInfo.badgeKey];
    self.badgeLabel.hidden = !self.badgeLabel.text.length;
    CGSize size=[self.badgeLabel.text stringSizeWithFont:self.badgeLabel.font];
    [self.badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width+8);
    }];
    self.badgeLabelBackView.hidden = self.badgeLabel.hidden;
    if(!self.badgeLabelBackView.hidden){
        self.badgeLabelBackView.image = [self badgeLabelBackImageWith:self.badgeLabel.text width:size.width+8 height:BadgeHeight];
        [self.badgeLabelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(size.width+8);
        }];
    }
}

-(UIImage*)badgeLabelBackImageWith:(NSString*)text width:(CGFloat)width height:(CGFloat)height
{
    if([text isEqualToString:@"全景"]){
        return [GradientTool imageWithColors:@[[UIColor colorWithHexString:@"#35baeb"],[UIColor colorWithHexString:@"#2b83dd"]] gradientType:GradientTypeLeftToRight imageSize:CGSizeMake(width, height)];
    }else if([text isEqualToString:@"会员"]){
        return [GradientTool imageWithColors:@[[UIColor colorWithHexString:@"#f0ca80"],[UIColor colorWithHexString:@"#d2a76a"]] gradientType:GradientTypeLeftToRight imageSize:CGSizeMake(width, height)];
    }
    return [GradientTool imageWithColors:@[[UIColor colorWithHexString:@"#ff6547"],[UIColor colorWithHexString:@"#f71e4c"]] gradientType:GradientTypeLeftToRight imageSize:CGSizeMake(width, height)];
}


- (void)addBadgeLabel {
    UIImageView *badgeLabelBackView = [UIImageView new];
    self.badgeLabelBackView = badgeLabelBackView;
    [self.imageView addSubview:badgeLabelBackView];
    badgeLabelBackView.hidden=YES;
    badgeLabelBackView.alpha=0.9;
    
    UILabel *badgeLabel = [UILabel new];
    badgeLabel.font = UIFontV5_10;
    badgeLabel.textColor = UIColorV6_FFFFFF;
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel = badgeLabel;
    [self.imageView addSubview:badgeLabel];
}


- (void)addDateLabel {
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font =  UIFontV5_13;
    titleLabel.textColor = UIColorV6_999999;
    self.dateLabel = titleLabel;
    [self addSubview:titleLabel];
}

- (void)addTitleLabel {
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font =  UIFontV5_13;
    titleLabel.textColor = UIColorV6_FFFFFF;
    self.titleLabel = titleLabel;
    [self.imageView addSubview:titleLabel];
}

-(void)addTipBackgroundView
{
    UIImageView *tipBackgroundView = [UIImageView new];
    tipBackgroundView.image = [[UIImage imageNamed:@"titleLabelBack"] resizableImage];
    self.tipBackgroundView = tipBackgroundView;
    [self.imageView addSubview:tipBackgroundView];
}

- (void)addLineImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"Channel-Appointments-Timeline"];
    self.lineImageView = imageView;
    [self addSubview:imageView];
}

- (void)addImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.userInteractionEnabled = YES;
    self.imageView = imageView;
    [self addSubview:imageView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap)];
    [imageView addGestureRecognizer:tap];
}

- (void)addButton
{
    SVMemberReservationButton *button = [SVMemberReservationButton new];
    self.button = button;
    [self addSubview:button];
    [button addTarget:self action:@selector(memberReservation) forControlEvents:UIControlEventTouchUpInside];
}

-(void)imageViewTap
{
    if([self.viewController isKindOfClass:[SVColumnsTableViewController class]]){
        [[LogCenter sharedCenter] loggingChannelMemberReservationClickWith:[self.dic stringForKey:@"aid"] index:self.indexPath columnID:self.columnID];
        
        VideoAlbum *videoAlbum = [VideoAlbum videoAlbumWithAlbumInfoJSONDictionary:self.dic];
        
        SVColumnsTableViewController* viewController = (SVColumnsTableViewController*)self.viewController;
        [self.viewController showViewControllerWithVideoAlbum:videoAlbum
                                      userInfo:@{ kUserInfoKeyPlayerSourceID: viewController.channelItem.channelEd OR @"",
                                                  kUserInfoKeyVideoColumnID: @(self.columnID),
                                                  kUserInfoKeyVideoIndex: @(self.indexPath)}
                                      animated:YES];
    }
}

-(void)memberReservation
{
    if(!self.button.selected){
        if (![UserCenter shareInstance].currentUserIsValid) {
            [LoginViewController presentLoginViewControllerInViewController:self.viewController loginEntrance:LoginEntrance_Unknown loginCallback:^{
                if([self.viewController isKindOfClass:[SVColumnsTableViewController class]]){
                    
                    SVColumnsTableViewController* viewController = (SVColumnsTableViewController*)self.viewController;
                    viewController.currentCursor = 0;
                    [viewController loadColumnVideos:^{
                    } failure:^{
                    }];
                }
            }];
        }else{
            [self memberReservationAdd];
        }
    }else{
        if (![UserCenter shareInstance].currentUserIsValid) {
            [LoginViewController presentLoginViewControllerInViewController:self.viewController loginEntrance:LoginEntrance_Unknown loginCallback:^{
                if([self.viewController isKindOfClass:[SVColumnsTableViewController class]]){
                    
                    SVColumnsTableViewController* viewController = (SVColumnsTableViewController*)self.viewController;
                    viewController.currentCursor = 0;
                    [viewController loadColumnVideos:^{
                    } failure:^{
                    }];
                }
            }];
        }else{
            [self memberReservationCancel];
        }
    }
}

-(void)memberReservationAdd
{
    NSString* aid = [NSString stringWithFormat:@"%@_%@_%@",[self.dic stringForKey:@"aid"],@"1", @"0"];
    
    [[LogCenter sharedCenter] loggingChannelMemberReservationAddClickWith:[self.dic stringForKey:@"aid"] index:self.indexPath columnID:self.columnID];

    SVRequestInfo *requestInfo =[SVColumnVideosRequestInfo requestInfoForV4MemberReservationWithAid:aid passport:[UserCenter shareInstance].getCurrentUser.passport];
    requestInfo.owner = self;
    
    weakify(self);
    [requestInfo setSuccess:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        strongify(self);
        
        NSArray *relationArray = (NSArray*)responseObject;
        NSDictionary* relationDic = relationArray.firstObject;
        
        BOOL success = [relationDic boolForKey:@"result"];
        
        if(success){
            [self.dic setBool:YES forKey:@"feed"];
            [self updateWithTemplate:self.templateInfo dataDic:self.dic columnID:self.columnID indexPath:self.indexPath];
            
            if([self isPushSwitchAvailable]){
                [GrowlView showMessage:@"预约成功!\n您可前往\"我的\"查看预约节目" animated:YES];
            }else{
                [GrowlView showMessage:@"预约成功!\n请在系统设置中打开通知权限" animated:YES];
            }
        }else{
            [GrowlView showMessage:@"预约失败，请稍后重试" animated:YES];
        }

        DDLogVerbose(@"%@ - url: %@", _HERE, responseInfo.request.URL);

    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        
        NSLog(@"%@ - url: %@", _HERE, responseInfo.request.URL);
        
        [GrowlView showMessage:@"预约失败，请稍后重试" animated:YES];
    }];
    
    [requestInfo send];
}

-(void)memberReservationCancel
{
    NSString* aid = [NSString stringWithFormat:@"%@_%@_%@",[self.dic stringForKey:@"aid"], @"1", @"0"];
    
    [[LogCenter sharedCenter] loggingChannelMemberReservationRemoveClickWith:[self.dic stringForKey:@"aid"] index:self.indexPath columnID:self.columnID];

    SVRequestInfo *requestInfo =[SVColumnVideosRequestInfo requestInfoForV4MemberReservationCancelWithAid:aid passport:[UserCenter shareInstance].getCurrentUser.passport];
    requestInfo.owner = self;
    
    weakify(self);
    [requestInfo setSuccess:^(id<M9ResponseInfo> responseInfo, id responseObject) {
        strongify(self);
        
        NSArray *relationArray = (NSArray*)responseObject;
        NSDictionary* relationDic = relationArray.firstObject;
        
        BOOL success = [relationDic boolForKey:@"result"];

        if(success){
            [self.dic setBool:NO forKey:@"feed"];
            [self updateWithTemplate:self.templateInfo dataDic:self.dic columnID:self.columnID indexPath:self.indexPath];
            
            [GrowlView showMessage:@"已取消预约" animated:YES];
        }else{
            [GrowlView showMessage:@"取消预约失败" animated:YES];
        }
        
        DDLogVerbose(@"%@ - url: %@", _HERE, responseInfo.request.URL);
        
    } failure:^(id<M9ResponseInfo> responseInfo, NSError *error) {
        
        NSLog(@"%@ - url: %@", _HERE, responseInfo.request.URL);
        [GrowlView showMessage:@"取消预约失败" animated:YES];
    }];
    
    [requestInfo send];
}

- (BOOL) isPushSwitchAvailable{
    BOOL isRemoteNotify = NO;
    if (IS_IOS8_LATER) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            isRemoteNotify = YES;
        }
    } else {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        isRemoteNotify = (type & UIRemoteNotificationTypeAlert || type & UIRemoteNotificationTypeSound || type & UIRemoteNotificationTypeBadge);
    }
    return isRemoteNotify;
}


@end
