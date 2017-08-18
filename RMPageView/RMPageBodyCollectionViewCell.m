//
//  RMPageBodyCollectionViewCell.m
//  RMPageController
//
//  Created by RaoMeng on 2017/5/22.
//  Copyright © 2017年 TianyingJiuzhou Network Technology Co. Ltd. All rights reserved.
//

#import "RMPageBodyCollectionViewCell.h"

@implementation RMPageBodyCollectionViewCell


-(void)setBodyController:(UIViewController *)bodyController {
    
    _bodyController = bodyController;
    if (bodyController) {
        [self.contentView addSubview:bodyController.view];
    }
    
}


@end
