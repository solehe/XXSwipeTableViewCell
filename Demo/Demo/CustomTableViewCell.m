//
//  CustomTableViewCell.m
//  Demo
//
//  Created by solehe on 2021/2/20.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (XXSwipeItemView *)itemView1 {
    
    if (!_itemView1) {
            
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundColor:[UIColor purpleColor]];
        [button setTitle:@"xx1" forState:UIControlStateNormal];
        
        _itemView1 = [XXSwipeItemView itemWithCustomView:button width:74.f];
    }
    return _itemView1;
}

- (XXSwipeItemView *)itemView2 {
    
    if (!_itemView2) {
            
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundColor:[UIColor blueColor]];
        [button setTitle:@"xx2" forState:UIControlStateNormal];
        
        _itemView2 = [XXSwipeItemView itemWithCustomView:button width:74.f];
    }
    return _itemView2;
}

- (XXSwipeItemView *)itemView3 {
    
    if (!_itemView3) {
            
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundColor:[UIColor redColor]];
        [button setTitle:@"xx3" forState:UIControlStateNormal];
        
        _itemView3 = [XXSwipeItemView itemWithCustomView:button width:74.f];
        _itemView3.type = XXSwipeItemTypeDestructive;
    }
    return _itemView3;
}

#pragma mark -

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setItemViews:@[self.itemView1, self.itemView2, self.itemView3]];
    }
    return self;
}


@end
