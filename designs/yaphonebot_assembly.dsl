module yaphonebot_assembly

# Full PhoneBot assembly: torso + left leg + right leg in zero (standing) pose.
#
# +X forward, +Y left, +Z up.  Origin at torso yaw joint centre.

# ===========================================================================
# DYNAMIXEL XL430-W250-T servo envelope
# ===========================================================================
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

# ===========================================================================
# Leg parametric constants
# ===========================================================================
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

# ===========================================================================
# Leg structural links
# ===========================================================================
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

# ===========================================================================
# Single leg  (s = +1 left, s = -1 right)
# ===========================================================================
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

# ===========================================================================
# Torso
# ===========================================================================
command TORSO_YAW_JOINT(x: float, y: float, z: float) -> solid:
    emit translate(XL430_ENVELOPE(), x, y, z)

command UPPER_BODY_PLATE() -> solid:
    emit translate(box(80.0, 100.0, 8.0), 0.0, 0.0, 20.0)

command PHONE_CRADLE() -> solid:
    base: solid = box(78.0, 158.0, 4.0)
    lw: solid   = box(4.0, 158.0, 20.0)
    rw: solid   = box(4.0, 158.0, 20.0)
    bw: solid   = box(78.0, 4.0, 20.0)
    emit compound(
        translate(base, 0.0, 0.0, 28.0),
        translate(lw, -39.0, 0.0, 28.0),
        translate(rw, 39.0, 0.0, 28.0),
        translate(bw, 0.0, 77.0, 28.0)
    )

command SBC_SHELF() -> solid:
    shelf: solid = box(90.0, 60.0, 4.0)
    riser: solid = box(90.0, 60.0, 15.0)
    emit compound(
        translate(shelf, 0.0, -55.0, 30.0),
        translate(riser, 0.0, -55.0, 22.0)
    )

command BATTERY_COMPARTMENT() -> solid:
    comp: solid = box(50.0, 125.0, 30.0)
    inner: solid = box(44.0, 119.0, 26.0)
    hull: solid = difference(comp, translate(inner, 0.0, 0.0, 4.0))
    emit translate(hull, 0.0, 0.0, -20.0)

command LOWER_BODY_PLATE() -> solid:
    emit translate(box(80.0, 100.0, 8.0), 0.0, 0.0, -28.0)

command LEG_TOWER(side: int) -> solid:
    require side == -1 or side == 1, "side must be -1 or +1"
    tower: solid = box(30.0, 20.0, 28.0)
    bore: solid = cylinder(5.0, 30.0)
    bore_rotated: solid = rotate(bore, 90.0, 0.0, 0.0)
    bored_tower: solid = difference(tower, translate(bore_rotated, 0.0, 0.0, 0.0))
    emit translate(bored_tower, side * 40.0, 0.0, -14.0)

command TORSO() -> solid:
    emit compound(
        TORSO_YAW_JOINT(0.0, 0.0, 0.0),
        UPPER_BODY_PLATE(),
        PHONE_CRADLE(),
        SBC_SHELF(),
        BATTERY_COMPARTMENT(),
        LOWER_BODY_PLATE(),
        LEG_TOWER(1),
        LEG_TOWER(-1)
    )

# ===========================================================================
# Top-level commands
# ===========================================================================
command PHONEBOT_ZERO_POSE() -> solid:
    emit compound(TORSO(), LEFT_LEG(), RIGHT_LEG())

command PHONEBOT_ASSEMBLY() -> assembly:
    a0: assembly = assembly("PhoneBot v0.1")
    a1: assembly = add_part(a0, TORSO(), "torso")
    a2: assembly = add_part(a1, LEFT_LEG(), "left_leg")
    a3: assembly = add_part(a2, RIGHT_LEG(), "right_leg")
    emit a3