module yaphonebot_assembly

# Full PhoneBot assembly: torso + left leg + right leg in zero (standing) pose.
# +X forward, +Y left, +Z up.  Origin at torso yaw joint centre.
#
# NOTE: No 'use as' aliases yet — the alias prefixing would break internal
# command references. Without aliases, shared primitives (XL430_*) from
# servo.dsl are identical across modules, so deduplication is harmless.

use yaphonebot_leg
use yaphonebot_torso

# === Top-level commands ====================================================
command PHONEBOT_ZERO_POSE() -> solid:
    emit compound(TORSO(), LEFT_LEG(), RIGHT_LEG())

command PHONEBOT_ASSEMBLY() -> assembly:
    a0: assembly = assembly("PhoneBot v0.1")
    a1: assembly = add_part(a0, TORSO(), "torso")
    a2: assembly = add_part(a1, LEFT_LEG(), "left_leg")
    a3: assembly = add_part(a2, RIGHT_LEG(), "right_leg")
    emit a3