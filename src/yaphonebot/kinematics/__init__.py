# yapPhoneBot — Kinematics

"""
Forward kinematics for the PhoneBot 13-DoF humanoid chain.

Joint order (per leg, proximal → distal):
    J0  Hip yaw     (Z)
    J1  Hip roll    (X)
    J2  Hip pitch   (Y)
    J3  Knee pitch  (Y)
    J4  Ankle pitch (Y)
    J5  Ankle roll  (X)

Torso:
    J6  Torso yaw   (Z)

Total: 7 per leg chain × 2 legs + torso, but the hip yaw/roll are
stacked so both legs share one torso yaw joint = 13 DoF.

Coordinate convention: +X forward, +Y left, +Z up (matches phonebot.dev).
"""
