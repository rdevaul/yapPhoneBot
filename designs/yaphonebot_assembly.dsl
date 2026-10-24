module yaphonebot_assembly

# Full PhoneBot assembly: torso + left leg + right leg in zero (standing) pose.
# +X forward, +Y left, +Z up.  Origin at torso yaw joint centre.

use yaphonebot_leg as leg
use yaphonebot_torso as torso

# === Top-level commands ====================================================
command PHONEBOT_ZERO_POSE() -> solid:
    emit compound(torso.TORSO(), leg.LEFT_LEG(), leg.RIGHT_LEG())

command PHONEBOT_ASSEMBLY() -> assembly:
    a0: assembly = assembly("PhoneBot v0.1")
    a1: assembly = add_part(a0, torso.TORSO(), "torso")
    a2: assembly = add_part(a1, leg.LEFT_LEG(), "left_leg")
    a3: assembly = add_part(a2, leg.RIGHT_LEG(), "right_leg")
    emit a3