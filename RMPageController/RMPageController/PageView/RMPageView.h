//
//  RMPageView.h
//  RMPageController
//
//  Created by RaoMeng on 2017/5/22.
//  Copyright © 2017年 TianyingJiuzhou Network Technology Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPageModel.h"

@class RMPageView;

@protocol RMPageViewDelegate <NSObject>

@optional

- (void)pageView:(RMPageView *)pageView endChangePageLastSelectedTabIndex:(NSInteger)lastSelectedTabIndex selectedTabIndex:(NSInteger)selectedTabIndex;

/**
 第二次点击标题

 @param pageView <#pageView description#>
 @param selectTabIndex <#selectTabIndex description#>
 */
- (void)pageView:(RMPageView *)pageView selectedTabIndex:(NSInteger )selectTabIndex;

@end

@interface RMPageView : UIView

/**
 子控器数组
 */
@property (nonatomic, strong) NSArray *childControllers;

/**
 子控制器标题数组
 */
@property (nonatomic, strong) NSArray<RMPageModel *> *childTitles;

/**
 设置当前选择item
 */
@property (nonatomic, assign) NSInteger selectedTabIndex;

/**
 设置一页最多显示的个数
 */
@property (nonatomic, assign) NSInteger maxNumberOfPageItems;

/**
 两个标题之间的距离
 */
@property (nonatomic, assign) CGFloat   spaceBetweenTabIndex;

/**
 item的size
 */
@property (nonatomic, assign) CGSize tabSize;

/**
 item的字体大小
 */
@property (nonatomic, strong) UIFont *tabItemFont;

/**
 未选择颜色
 */
@property (nonatomic, strong) UIColor *unSelectedColor;

/**
 当前选中颜色
 */
@property (nonatomic, strong) UIColor *selectedColor;

/**
 顶部标题的颜色背景色，默认white
 */
@property (nonatomic, strong) UIColor *tabBackgroundColor;

/**
 下标高度，默认是2.0
 */
@property (nonatomic, assign) CGFloat indicatorHeight;

/**
 下标宽度，默认是0。
 */
@property (nonatomic, assign) CGFloat indicatorWidth;

/**
 字体渐变，未选择的item的scale
 */
@property (nonatomic, assign) CGFloat minScale;

/**
 滑动代理
 */
@property (nonatomic, assign) id<RMPageViewDelegate>delegate;


/**
 初始化View

 @param childControllers 子控器数组
 @param childTitles 子控制器标题数组
 @return <#return value description#>
 */
- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)childControllers childTitles:(NSArray<RMPageModel *> *)childTitles ;

@end
