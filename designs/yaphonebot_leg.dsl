module yaphonebot_leg

# PhoneBot leg kinematic chain (6 DoF per leg).
#
# Joint order (proximal to distal), matching phonebot.dev datums:
#   J1  Hip yaw (Z), J2  Hip roll (X), J3  Hip pitch (Y)
#   J4  Knee pitch (Y), J5  Ankle pitch (Y), J6  Ankle roll (X)
#
# +X forward, +Y left, +Z up.  Left leg shown; right leg mirrored.

use yaphonebot_servo

# === Parametric constants ==================================================
command HIP_OFFSET_Y() -> float:
    emit 50.0

command HIP_LENGTH_X() -> float:
    emit 32.0

command THIGH_LENGTH_Z() -> float:
    emit 96.0

command SHIN_LENGTH_Z() -> float:
    emit 96.0

command ANKLE_HEIGHT() -> float:
    emit 41.0

# === Structural links ======================================================
command THIGH_LINK() -> solid:
    len_z: float = THIGH_LENGTH_Z()
    link: solid = box(28.0, 20.0, len_z)
    emit translate(link, 0.0, 0.0, len_z / 2.0)

command SHIN_LINK() -> solid:
    len_z: float = SHIN_LENGTH_Z()
    link: solid = box(24.0, 18.0, len_z)
    emit translate(link, 0.0, 0.0, len_z / 2.0)

command FOOT_PLATE() -> solid:
    plate: solid = box(40.0, 60.0, 8.0)
    emit translate(plate, 0.0, 0.0, -4.0)

# === Single leg ============================================================
command SINGLE_LEG(s: float) -> solid:
    ho: float = HIP_OFFSET_Y()
    hl: float = HIP_LENGTH_X()
    tl: float = THIGH_LENGTH_Z()
    sl: float = SHIN_LENGTH_Z()
    ah: float = ANKLE_HEIGHT()

    srv_y: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    srv_x: solid = rotate(XL430_ENVELOPE(), 0.0, 90.0, 0.0)

    hip_yaw: solid   = translate(XL430_ENVELOPE(), 0.0, ho * s, 0.0)
    hip_roll: solid  = translate(srv_x, 0.0, ho * s, -18.0)
    hip_pitch: solid = translate(srv_y, 0.0, ho * s, -hl - 18.0)
    thigh: solid     = translate(THIGH_LINK(), 0.0, ho * s, -hl - 18.0)

    knee_y: float      = -hl - 18.0 - tl
    knee_pitch: solid  = translate(srv_y, 0.0, ho * s, knee_y)
    shin: solid        = translate(SHIN_LINK(), 0.0, ho * s, knee_y)

    ankle_pitch_y: float = knee_y - sl
    ankle_pitch: solid   = translate(srv_y, 0.0, ho * s, ankle_pitch_y)
    ankle_roll: solid    = translate(srv_x, 0.0, ho * s, ankle_pitch_y - 18.0)

    foot_z: float = ankle_pitch_y - ah
    foot: solid   = translate(FOOT_PLATE(), 0.0, ho * s, foot_z)

    emit compound(
        hip_yaw, hip_roll, hip_pitch, thigh,
        knee_pitch, shin, ankle_pitch, ankle_roll, foot
    )

command LEFT_LEG() -> solid:
    emit SINGLE_LEG(1.0)

command RIGHT_LEG() -> solid:
    left: solid = LEFT_LEG()
    emit mirror(left, vector(0.0, 1.0, 0.0))