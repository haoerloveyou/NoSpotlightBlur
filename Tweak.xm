#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import "Interfaces.h"

#define kiOS7 (kCFCoreFoundationVersionNumber >= 847.20 && kCFCoreFoundationVersionNumber <= 847.27)
#define kiOS8 (kCFCoreFoundationVersionNumber >= 1140.10 && kCFCoreFoundationVersionNumber >= 1145.15)
#define kiOS9 (kCFCoreFoundationVersionNumber == 1240.10)

static NSDictionary *prefs = nil;
static CFStringRef applicationID = CFSTR("com.noahdev.nospotlightblur");

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
        prefs = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        CFRelease(keyList);
    }
}

%group iOS9
%hook SBSearchViewController //spotight from top
- (void)willBeginPresentingAnimated:(BOOL)animated fromSource:(unsigned int)source {
    %orig();

    if ([prefs[@"kEnabled"] boolValue]) {
        UIView *view = MSHookIvar<UIView *>(self, "_searchBackdrop");
        [view setHidden:YES];
    }
}
%end

%hook SBRootFolderView //right edge spotlight
- (void)_animateViewsForScrollingToSearch {
    %orig();

    UIView *view = MSHookIvar<UIView *>(self, "_searchBlurEffectView");
    [view setHidden:[prefs[@"kEnabled"] boolValue]];
}
%end
%end

%group iOS8 //TODO:
%end

%group iOS7 //TODO:
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)LoadPreferences,
                                    CFSTR("NoahDevNoSpotLightBlurPreferencesChangedNotification"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    LoadPreferences();

    if (kiOS9)
        %init(iOS9);
    if (kiOS8)
        %init(iOS8);
    if (kiOS7)
        %init(iOS7)
}
