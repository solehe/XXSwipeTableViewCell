//
//  XXSwipeTableViewCell.h
//  WeTalk
//
//  Created by solehe on 2021/2/18.
//  Copyright © 2021 itechblack Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XXSwipeTableViewCellDelegate;

typedef NS_ENUM(NSInteger, XXSwipeItemType) {
    XXSwipeItemTypeNormal,
    XXSwipeItemTypeDestructive
};

@interface XXSwipeItemView : UIView

@property (nonatomic, assign) XXSwipeItemType type;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, assign) CGFloat width;

- (instancetype)initWithCustomView:(UIView *)view width:(CGFloat)width;
+ (instancetype)itemWithCustomView:(UIView *)view width:(CGFloat)width;

@end


@interface XXSwipeTableViewCell : UITableViewCell

/// 代理
@property (nonatomic, weak) id<XXSwipeTableViewCellDelegate> swipeDelegate;
/// 右侧滑动展示的视图集合
@property (nonatomic, strong) NSArray<XXSwipeItemView *> *itemViews;
/// 右侧滑动展示的视图集合父视图
@property (nonatomic, strong, readonly) UIView *rightSwipeContentView;
/// 滑动手势
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;

/// 隐藏侧滑菜单视图
- (void)hiddenSwipeView;

@end


@protocol XXSwipeTableViewCellDelegate <NSObject>

@optional

- (void)swipeTableViewCell:(XXSwipeTableViewCell *)cell didClicked:(XXSwipeItemView *)swipeItemView;

@end


NS_ASSUME_NONNULL_END
