//
//  XXSwipeTableViewCell.m
//  WeTalk
//
//  Created by solehe on 2021/2/18.
//  Copyright © 2021 itechblack Pte. Ltd. All rights reserved.
//

#import "XXSwipeTableViewCell.h"

static NSString *WidthConstraint = @"WidthConstraint";

#pragma mark - XXSwipeOverlayView

@interface XXSwipeOverlayView : UIView

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) XXSwipeTableViewCell *cell;

@end

@implementation XXSwipeOverlayView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGPoint p1 = [self convertPoint:point toView:self.cell];
    if (CGRectContainsPoint(self.cell.bounds, p1)) {
        
        CGPoint p2 = [self convertPoint:point toView:self.cell.rightSwipeContentView];
        if (CGRectContainsPoint(self.cell.rightSwipeContentView.bounds, p2)) {
            return [self.cell.rightSwipeContentView hitTest:p2 withEvent:event];
        } else {
            return nil;
        }
        
    } else {
     
        [self.cell hiddenSwipeView];
        
        return nil;
    }
}

@end

#pragma mark - XXSwipeItemView

@protocol XXSwipeItemViewDelegate <NSObject>

@optional
- (void)swipeItemView:(XXSwipeItemView *)swipeItemView didClicked:(UIView *)customView;

@end

@interface XXSwipeItemView ()

@property (nonatomic, weak) id<XXSwipeItemViewDelegate> delegate;

@end

@implementation XXSwipeItemView

+ (instancetype)itemWithCustomView:(UIView *)view width:(CGFloat)width {
    return [[self alloc] initWithCustomView:view width:width];
}

- (instancetype)initWithCustomView:(UIView *)view width:(CGFloat)width {
    
    if (self = [super init]) {
        
        _customView = view;
        _width = width;
        
        [self initView];
    }
    return self;
}

- (void)initView {
    
    [self setBackgroundColor:_customView.backgroundColor];
    [self addSubview:_customView];
    
    // 如果是按钮，则需要拦截添加点击事件
    if ([_customView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)_customView;
        if (button.allTargets.count <= 0) {
            [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    // 否则添加点击手势
    else if (_customView.gestureRecognizers.count <= 0) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapAction:)];
        [_customView setUserInteractionEnabled:YES];
        [_customView addGestureRecognizer:tapGesture];
    }
}

#pragma mark -

- (void)tapAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(swipeItemView:didClicked:)]) {
        [self.delegate swipeItemView:self didClicked:self.customView];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 更新坐标尺寸
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = MAX(CGRectGetWidth(self.bounds), self.width);
    [self.customView setFrame:CGRectMake(0, 0, width, height)];
}

@end


#pragma mark - XXSwipeTableViewCell

@interface XXSwipeTableViewCell ()
<
    XXSwipeItemViewDelegate,
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) XXSwipeOverlayView *swipeOverlayView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) BOOL isCanceling;
@property (nonatomic, assign) BOOL isDestructive;

@end

@implementation XXSwipeTableViewCell

@synthesize panGesture = _panGesture;
@synthesize rightSwipeContentView = _rightSwipeContentView;

#pragma mark -

- (void)dealloc {
    [self.contentView removeObserver:self forKeyPath:@"frame" context:nil];
}

#pragma mark -

- (XXSwipeOverlayView *)swipeOverlayView {
    if (!_swipeOverlayView) {
        _swipeOverlayView = [[XXSwipeOverlayView alloc] init];
        [_swipeOverlayView setBackgroundColor:[UIColor clearColor]];
        [_swipeOverlayView setTableView:[self getTableView]];
        [_swipeOverlayView setCell:self];
    }
    return _swipeOverlayView;
}

- (UIView *)rightSwipeContentView {
    if (!_rightSwipeContentView) {
        _rightSwipeContentView = [[UIView alloc] init];
        [_rightSwipeContentView setAutoresizesSubviews:NO];
        [self.contentView addSubview:_rightSwipeContentView];
    }
    return _rightSwipeContentView;
}

- (UIPanGestureRecognizer *)panGesture {
    
    if (!_panGesture) {
        
        _panGesture = [[UIPanGestureRecognizer alloc] init];
        [_panGesture setDelegate:self];
        [_panGesture addTarget:self action:@selector(panAction:)];
        [self.contentView addGestureRecognizer:_panGesture];
        
        [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] init];
        [_tapGesture addTarget:self action:@selector(hiddenSwipeView)];
    }
    return _tapGesture;
}

#pragma mark - 视图初始化

- (void)setItemViews:(NSArray<XXSwipeItemView *> *)itemViews {
    
    _itemViews = [itemViews copy];
    
    [self initView];
    
    [self initLayout];
}

- (void)initView {
    
    // 移除之前添加的子视图
    if (self.rightSwipeContentView.subviews.count > 0) {
        for (UIView *subView in self.rightSwipeContentView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    // 重新添加子视图
    for (XXSwipeItemView *swipeItemView in self.itemViews) {
        [swipeItemView.customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [swipeItemView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [swipeItemView setDelegate:self];
        [self.rightSwipeContentView addSubview:swipeItemView];
    }

    // 重新添加滑动手势
    [self.panGesture setEnabled:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isEqual:self.panGesture]) {
        
        if (self.isEditing) {
            [self hiddenAllSwipeView];
            return NO; //do not swipe while editing table
        }
        
        CGPoint translation = [self.panGesture translationInView:self];
        if (fabs(translation.y) > fabs(translation.x)) {
            [self hiddenAllSwipeView];
            return NO; // user is scrolling vertically
        }
        
        // 隐藏所有侧滑视图
        [self hiddenOthersSwipeView];
    }
    
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (XXSwipeItemView *swipeItemView in self.itemViews) {
        
        CGPoint p = [self convertPoint:point toView:swipeItemView];
        if (CGRectContainsPoint(swipeItemView.bounds, p)) {
            return [swipeItemView hitTest:p withEvent:event];
        }
    }
    
    // 当前视图响应
    return [super hitTest:point withEvent:event];
}

#pragma mark - XXSwipeItemViewDelegate

- (void)swipeItemView:(XXSwipeItemView *)swipeItemView didClicked:(UIView *)customView {
    
    // 需要二次确认，实现效果
    if (swipeItemView.type == XXSwipeItemTypeDestructive &&
        CGRectGetWidth(swipeItemView.bounds) != [self calculateSwipeTotalWidth]) {
        
        [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self updateLayoutWithDisplayView:swipeItemView];
            [self.rightSwipeContentView layoutIfNeeded];

        } completion:^(BOOL finished) {
        }];
        
        return;
    }
    
    // 返回点击事件
    if ([self.swipeDelegate respondsToSelector:@selector(swipeTableViewCell:didClicked:)]) {
        [self.swipeDelegate swipeTableViewCell:self didClicked:swipeItemView];
    }
}

#pragma mark - 交互

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    
    CGPoint point = [gesture translationInView:gesture.view];
    
    UIGestureRecognizerState state = gesture.state;
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    // 滑动
    if (state == UIGestureRecognizerStateChanged) {
        
        CGFloat totalSwipeWidth = [self calculateSwipeTotalWidth];
        
        CGRect contentFrame = self.contentView.frame;
        CGRect swipeFrame = self.rightSwipeContentView.frame;

        if (contentFrame.origin.x + point.x <= -totalSwipeWidth) {
            
            // 超过最大距离，加阻尼
            CGFloat hindrance = (point.x / 5.f);
            if (contentFrame.origin.x + hindrance <= -totalSwipeWidth) {
                
                contentFrame.origin.x += hindrance;
                swipeFrame.size.width += -hindrance;
                swipeFrame.origin.x += hindrance;
                
            } else { // 当滑动过快时，会导致最初减速时闪动
                
                contentFrame.origin.x = -totalSwipeWidth;
                swipeFrame.origin.x = CGRectGetWidth(contentFrame) - totalSwipeWidth;
            }
            
        } else { // 未到最大距离，正常拖拽
            
            contentFrame.origin.x += point.x;
            swipeFrame.origin.x += point.x;
        }
        
        // 不允许右滑
        if (contentFrame.origin.x > 0.f) {
            contentFrame.origin.x = 0.f;
        }
        
        // 判断结束时是否取消展示
        [self setIsCancel:(CGRectGetMinX(self.contentView.frame) < CGRectGetMinX(contentFrame))];
        
        // 重设坐标
        [self.contentView setFrame:contentFrame];
        [self adjustOffsetX:CGRectGetMinX(self.contentView.frame)];
    }
    // 结束、取消
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        
        [self refreshSwipeViewDisplay];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"frame"] &&
        CGRectGetWidth(self.rightSwipeContentView.bounds) > 0.f &&
        CGRectGetMinX(self.contentView.frame) >= 0.f) {
        [self hiddenSwipeView];
    }
}

- (void)adjustOffsetX:(CGFloat)offsetX {
    
    // 更新右侧菜单控件尺寸
    CGFloat x = CGRectGetMaxX(self.contentView.bounds);
    CGRect frame = CGRectMake(x, 0, fabs(offsetX), CGRectGetHeight(self.bounds));
    [self.rightSwipeContentView setFrame:frame];
    
    // 展示遮罩层
    if (offsetX < 0.f && !self.swipeOverlayView.superview) {
        UITableView *tableView = [self getTableView];
        [self.swipeOverlayView setFrame:tableView.bounds];
        [tableView addSubview:self.swipeOverlayView];
        [self addGestureRecognizer:self.tapGesture];
    }
    // 隐藏遮罩层
    else if (offsetX >= 0.f && self.swipeOverlayView.superview) {
        [self.swipeOverlayView removeFromSuperview];
        [self removeGestureRecognizer:self.tapGesture];
    }
    
    // 判断是否需要还原
    if (self.isDestructive && offsetX < 0.f && offsetX >= -30.f) {
        [self updateLayoutWithDisplayView:nil];
    }
}

- (void)refreshSwipeViewDisplay {
    
    if (CGRectGetMinX(self.contentView.frame) < 0.f) {
        
        [self setIsCanceling:YES];
        
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
            
            CGRect contentFrame = self.contentView.frame;
            contentFrame.origin.x = self.isCancel ? 0.f : -[self calculateSwipeTotalWidth];
            
            if (!self.isCancel) {
                [self adjustOffsetX:CGRectGetMinX(contentFrame)];
                [self.rightSwipeContentView layoutIfNeeded]; // 如果使用的是约束，一定要写这句，否则动画不会执行
            }
            
            [self.contentView setFrame:contentFrame];

        } completion:^(BOOL finished) {

            [self adjustOffsetX:CGRectGetMinX(self.contentView.frame)];
            
            if (self.isCancel) {
                [self updateLayoutWithDisplayView:nil];
            }
            
            [self setIsCanceling:NO];
        }];
        
    } else if (self.isCancel && !self.isCanceling) {
        
        [self setIsCanceling:YES];
        
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
            
            [self adjustOffsetX:CGRectGetMinX(self.contentView.frame)];

        } completion:^(BOOL finished) {

            [self updateLayoutWithDisplayView:nil];
            
            [self setIsCanceling:NO];
        }];
    }
}

#pragma mark -

- (void)hiddenSwipeView {
    if (CGRectGetMinX(self.contentView.frame) < 0.f ||
        [self.gestureRecognizers containsObject:self.tapGesture] ||
        [self.swipeOverlayView superview]) {
        [self setIsCancel:YES];
        [self refreshSwipeViewDisplay];
    }
}

- (void)hiddenAllSwipeView {
    for (UITableViewCell *cell in [self getTableView].visibleCells) {
        if ([cell isKindOfClass:[XXSwipeTableViewCell class]]) {
            [(XXSwipeTableViewCell *)cell hiddenSwipeView];
        }
    };
}

- (void)hiddenOthersSwipeView {
    for (UITableViewCell *cell in [self getTableView].visibleCells) {
        if (![cell isEqual:self] && [cell isKindOfClass:[XXSwipeTableViewCell class]]) {
            [(XXSwipeTableViewCell *)cell hiddenSwipeView];
        }
    };
}

#pragma mark - 布局

- (void)initLayout {
    
    // 初始化右侧菜单位置
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.rightSwipeContentView setFrame:CGRectMake(width, 0, 0, 0)];
    
    // 添加右侧菜单布局空间
    UILayoutGuide *container = [[UILayoutGuide alloc] init];
    [self.rightSwipeContentView addLayoutGuide:container];
    
    CGFloat totalSwipeWidth = [self calculateSwipeTotalWidth];

    // 设置子控件约束
    for (int i=0; i<self.itemViews.count; i++) {

        XXSwipeItemView *itemView = [self.itemViews objectAtIndex:i];
        
        // 宽度约束
        CGFloat scale = (itemView.width / totalSwipeWidth);
        NSLayoutDimension *widthAnchor = self.rightSwipeContentView.widthAnchor;
        NSLayoutConstraint *constraint = [itemView.widthAnchor constraintEqualToAnchor:widthAnchor multiplier:scale];
        [constraint setIdentifier:WidthConstraint];
        [constraint setActive:YES];
        
        // 左侧约束
        if (i == 0) {
            [[itemView.leadingAnchor constraintEqualToAnchor:self.rightSwipeContentView.leadingAnchor] setActive:YES];
        } else {
            [[itemView.leadingAnchor constraintEqualToAnchor:self.itemViews[i-1].trailingAnchor] setActive:YES];
        }

        // 顶部约束
        [[itemView.topAnchor constraintEqualToAnchor:self.rightSwipeContentView.topAnchor] setActive:YES];

        // 底部约束
        [[itemView.bottomAnchor constraintEqualToAnchor:self.rightSwipeContentView.bottomAnchor] setActive:YES];

        // 右侧约束
        if (i == (self.itemViews.count-1)) {
            [[itemView.trailingAnchor constraintEqualToAnchor:self.rightSwipeContentView.trailingAnchor] setActive:YES];
        } else {
            [[itemView.trailingAnchor constraintEqualToAnchor:self.itemViews[i+1].leadingAnchor] setActive:YES];
        }
    }
}

- (void)updateLayoutWithDisplayView:(XXSwipeItemView * __nullable)swipeItemView {
    
    // 移除之前设置的宽度约束
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier=%@", WidthConstraint];
    NSArray<NSLayoutConstraint *> *constraints = [self.rightSwipeContentView.constraints filteredArrayUsingPredicate:predicate];
    if (constraints.count > 0) {
        [NSLayoutConstraint deactivateConstraints:constraints];
        [self.rightSwipeContentView removeConstraints:constraints];
    }
    
    // 计算右侧菜单栏的总宽度
    CGFloat totalSwipeWidth = [self calculateSwipeTotalWidth];
    
    //  更新子控件的宽度约束
    for (int i=0; i<self.itemViews.count; i++) {

        XXSwipeItemView *itemView = [self.itemViews objectAtIndex:i];
        
        if (itemView.superview != nil) {
         
            // 宽度约束
            if (!swipeItemView) {
                CGFloat scale = (itemView.width / totalSwipeWidth);
                NSLayoutDimension *widthAnchor = self.rightSwipeContentView.widthAnchor;
                NSLayoutConstraint *constraint = [itemView.widthAnchor constraintEqualToAnchor:widthAnchor multiplier:scale];
                [constraint setIdentifier:WidthConstraint];
                [constraint setActive:YES];
                [self setIsDestructive:NO];
            } else {
                CGFloat scale = ([itemView isEqual:swipeItemView] ? 1.f - 0.0001f * (self.itemViews.count-1) : 0.0001f);
                NSLayoutDimension *widthAnchor = self.rightSwipeContentView.widthAnchor;
                NSLayoutConstraint *constraint = [itemView.widthAnchor constraintEqualToAnchor:widthAnchor multiplier:scale];
                [constraint setIdentifier:WidthConstraint];
                [constraint setActive:YES];
                [self setIsDestructive:YES];
            }
        }
    }
}

- (CGFloat)calculateSwipeTotalWidth {
    
    CGFloat totalWidth = 0.f;
    
    for (XXSwipeItemView *swipeItemView in self.itemViews) {
        totalWidth += swipeItemView.width;
    }
    return totalWidth;
}

#pragma mark -

- (UITableView *)getTableView {
    UIView * view = self.superview;
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            return (UITableView*) view;
        }
        view = view.superview;
    }
    return nil;
}

@end
