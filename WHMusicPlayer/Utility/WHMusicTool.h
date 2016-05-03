//
//  WHMusicTool.h
//  WHMusicPlayer
//
//  Created by Wayne on 16/4/27.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHMusic.h"
@interface WHMusicTool : NSObject
+(NSArray*)musicArray;
+(void)setCurrentPlayingMusic:(WHMusic*)music;
+(WHMusic*)CurrentPlayingMusic;
+(WHMusic*)nextMusic;
+(WHMusic*)previousMusic;


+(NSArray<NSDictionary*> *)getLrc;
@end
