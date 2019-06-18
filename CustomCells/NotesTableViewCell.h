//
//  NotesTableViewCell.h
//  test-new-ui
//
//  Created by Mark on 18/04/2019.
//  Copyright © 2019 Mark McGuill. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotesTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^onNotesEdited)(NSString* notes);
@property (nonatomic, copy) void (^onNotesDoubleTap)(void);

- (void)setNotes:(NSString*)notes editable:(BOOL)editable;

@end

NS_ASSUME_NONNULL_END
