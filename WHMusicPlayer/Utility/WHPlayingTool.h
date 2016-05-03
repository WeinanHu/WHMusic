//
//  WHPlayingTool.h
//  WHMusicPlayer
//
//  Created by Wayne on 16/4/28.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WHPlayingTool : NSObject
+(AVAudioPlayer *)getAvAudioPlayer;
+(void)killPlayer;
+(NSTimeInterval)playingTime;
+(NSTimeInterval)playingOverTime;
+(void)setMusicTime:(NSTimeInterval)time;

@end
