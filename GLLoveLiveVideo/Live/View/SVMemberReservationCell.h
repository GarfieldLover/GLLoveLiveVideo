//
//  SVMemberReservationCell.h
//  iPhoneVideo
//
//  Created by ZK on 2016/10/31.
//  Copyright © 2016年 SOHU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerModel.h"


@interface SVMemberReservationCell : UICollectionViewCell

- (void)updateWithdataDic:(PlayerModel *)playerModel  indexPath:(NSInteger)indexPath;

@end

