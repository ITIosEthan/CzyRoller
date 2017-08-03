//
//  CzyImageRollerView.h
//  CzyImageRoller
//
//  Created by macOfEthan on 17/8/1.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CzyPageStyle){
    
    CzyPageStyleLabel = 0, //标签样式
    CzyPageStyleDot        //pageControl
};


@interface CzyImageRollerView : UIView

/**图片url数组**/
@property (nonatomic, strong) NSArray *imageUrls;

/**页码显示样式**/
@property (nonatomic, assign) CzyPageStyle pageStyle;


/**页码设置**/
- (void)setCurrentPage:(NSInteger)curentPage total:(NSUInteger)totalPage;

@end
