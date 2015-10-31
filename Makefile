include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoSpotlightBlur
NoSpotlightBlur_FILES = Tweak.xm
NoSpotlightBlur_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
