//
//  CzyRollerCell.h
//  CzyImageRoller
//
//  Created by macOfEthan on 17/8/1.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissBlock)(void);
typedef void(^HiddenBlock)(void);

@interface CzyRollerCell : UICollectionViewCell

/*下拉消失*/
@property (nonatomic, copy) DismissBlock dismissBlock;
/*单击隐藏或者显示*/
@property (nonatomic, copy) HiddenBlock hiddenBlock;


/*图片地址*/
@property (nonatomic, copy) NSString *imageUrl;
/*瀑布流*/
@property (nonatomic, strong) UICollectionView *collectionView;

@end
