//
//  RMPageTitleView.m
//  WeMedia
//
//  Created by RaoMeng on 2017/8/15.
//  Copyright © 2017年 TianyingJiuzhou Network Technology Co. Ltd. All rights reserved.
//

#import "RMPageTitleView.h"
#import "UIView+Frame.h"

@interface RMPageTitleView()

@property (nonatomic, strong) UIImageView *identifyImageView; // 标识图片
@property (nonatomic, assign) BOOL isLayout;  // 滑动的时候不允许修改，打开这个属性之后会因为滚动的大小出现抖动

@end

@implementation RMPageTitleView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (void) initView {
    
    _pageTitleLabel = [UILabel new];
    _pageTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_pageTitleLabel];
    _identifyImageView = [[UIImageView alloc]init];
    [self addSubview:_identifyImageView];
    _identifyImageView.hidden = YES; // 初始化的时候为隐藏
    _identifyImageView.image = [UIImage imageNamed:@"new"];
    self.isLayout = YES;
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (self.isLayout) {
        _identifyImageView.frame = CGRectMake(self.width - 19, self.centerY - 18, 14, 9);
        _pageTitleLabel.frame = self.bounds;
        self.isLayout = NO;
    }
}


- (void)setPageModel:(RMPageModel *)pageModel {
    
    _pageModel = pageModel;
    if (pageModel) {
        _pageTitleLabel.text = pageModel.title;
        _identifyImageView.hidden = !pageModel.isShowIndentifImageView;
    }
    
}


@end
