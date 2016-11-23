//
//  SVMemberReservationCell.h
//  iPhoneVideo
//
//  Created by ZK on 2016/10/31.
//  Copyright © 2016年 SOHU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVMemberReservationCell : UICollectionViewCell

- (void)updateWithTemplate:(SVTemplate *)templateInfo dataDic:(NSDictionary *)dic columnID:(NSInteger)columnID indexPath:(NSInteger)indexPath;

@end

