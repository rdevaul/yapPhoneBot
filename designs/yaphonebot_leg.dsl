module yaphonebot_leg

# PhoneBot leg kinematic chain (6 DoF per leg) modeled in yapCAD DSL.
#
# Joint order (proximal to distal), matching phonebot.dev datums:
#   J1  Hip yaw     (Z rotation)
#   J2  Hip roll    (X rotation)
#   J3  Hip pitch   (Y rotation)
#   J4  Knee pitch  (Y rotation)
#   J5  Ankle pitch (Y rotation)
#   J6  Ankle roll  (X rotation)
#
# Coordinate convention: +X forward, +Y left, +Z up.
# Left leg shown; right leg is mirrored.

# === DYNAMIXEL XL430-W250-T servo envelope (self-contained) ================
command XL430_BODY() -> solid:
    body: solid = box(28.0, 48.5, 33.5)
    emit body

command XL430_SHAFT() -> solid:
    shaft: solid = cylinder(2.55, 12.0)
    emit translate(shaft, 0.0, 0.0, 16.75)

command XL430_ENVELOPE() -> solid:
    body: solid = XL430_BODY()
    shaft: solid = XL430_SHAFT()
    emit union(body, shaft)

# === Parametric constants (mm) =============================================
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

# === Left leg zero pose ====================================================
command LEFT_LEG_ZERO_POSE(side: int = 1) -> solid:
    ho: float = HIP_OFFSET_Y()
    hl: float = HIP_LENGTH_X()
    tl: float = THIGH_LENGTH_Z()
    sl: float = SHIN_LENGTH_Z()
    ah: float = ANKLE_HEIGHT()
    s: float = float(side)

    srv_y: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    srv_x: solid = rotate(XL430_ENVELOPE(), 0.0, 90.0, 0.0)

    hip_yaw: solid = translate(XL430_ENVELOPE(), 0.0, ho * s, 0.0)
    hip_roll: solid = translate(srv_x, 0.0, ho * s, -18.0)
    hip_pitch: solid = translate(srv_y, 0.0, ho * s, -hl - 18.0)
    thigh: solid = translate(THIGH_LINK(), 0.0, ho * s, -hl - 18.0)

    knee_y: float = -hl - 18.0 - tl
    knee_pitch: solid = translate(srv_y, 0.0, ho * s, knee_y)
    shin: solid = translate(SHIN_LINK(), 0.0, ho * s, knee_y)

    ankle_pitch_y: float = knee_y - sl
    ankle_pitch: solid = translate(srv_y, 0.0, ho * s, ankle_pitch_y)
    ankle_roll: solid = translate(srv_x, 0.0, ho * s, ankle_pitch_y - 18.0)

    foot_z: float = ankle_pitch_y - ah
    foot: solid = translate(FOOT_PLATE(), 0.0, ho * s, foot_z)

    emit compound(
        hip_yaw, hip_roll, hip_pitch, thigh,
        knee_pitch, shin, ankle_pitch, ankle_roll, foot
    )

# === Right leg zero pose ===================================================
command RIGHT_LEG_ZERO_POSE() -> solid:
    left: solid = LEFT_LEG_ZERO_POSE(1)
    emit mirror(left, vector(0.0, 1.0, 0.0))