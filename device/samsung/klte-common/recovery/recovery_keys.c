#include <linux/input.h>

#include "recovery_ui.h"

int device_toggle_display(volatile char* key_pressed, int key_code) {
    return key_code == KEY_L &&
           (key_pressed[KEY_LEFTALT] || key_pressed[KEY_RIGHTALT]);
}

int device_handle_key(int key_code, int visible) {
    if (!visible) {
        return NO_ACTION;
    }

    switch (key_code) {
        case KEY_UP:
        case KEY_VOLUMEUP:
            return HIGHLIGHT_UP;
        case KEY_DOWN:
        case KEY_VOLUMEDOWN:
            return HIGHLIGHT_DOWN;
        case KEY_POWER:
        case KEY_HOMEPAGE:
        case KEY_HOME:
        case KEY_ENTER:
            return SELECT_ITEM;
        case KEY_BACK:
        case KEY_BACKSPACE:
            return GO_BACK;
        default:
            return NO_ACTION;
    }
}
