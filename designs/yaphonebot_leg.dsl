module yaphonebot_leg

# PhoneBot leg kinematic chain (6 DoF per leg) modeled in yapCAD DSL.
#
# Joint order (proximal → distal), matching phonebot.dev datums:
#   J1  Hip yaw     (Z-axis rotation)
#   J2  Hip roll    (X-axis rotation, offset from J1)
#   J3  Hip pitch   (Y-axis rotation)
#   J4  Knee pitch  (Y-axis rotation)
#   J5  Ankle pitch (Y-axis rotation)
#   J6  Ankle roll  (X-axis rotation)
#
# Coordinate convention: +X forward, +Y left, +Z up.
# Left leg shown; right leg is mirrored about the XZ plane.
#
# All dimensions from the phonebot.dev Onshape model / STEP exports,
# cross-referenced against the GrabCAD XL430 model.

# ---------------------------------------------------------------------------
# Constants (in mm) — adjust as we verify against reference STLs
# ---------------------------------------------------------------------------

param HIP_OFFSET_Y: float = 50.0      # half-body-width offset from midline
param HIP_LENGTH_X: float = 32.0      # hip pitch link length (servo body depth + bracket)
param THIGH_LENGTH_Z: float = 96.0    # thigh length (hip pitch → knee pitch)
param SHIN_LENGTH_Z: float = 96.0     # shin length (knee pitch → ankle pitch)
param ANKLE_HEIGHT: float = 41.0      # ankle pitch → ground (foot sole)

# ---------------------------------------------------------------------------
# Servo bracket: generic XL430 mount that clamps the servo body
# ---------------------------------------------------------------------------

command SERVO_BRACKET(width: float, depth: float, height: float) -> solid:
    # U-shaped bracket that wraps around a servo body.
    # Simplified: rectangular shell with servo-shaped inner cutout.
    let outer: solid = box(width, depth, height)
    let inner: solid = box(width - 4.0, depth - 4.0, height - 2.0)
    let shell: solid = difference(outer, translate(inner, 0.0, 0.0, 2.0))
    emit shell

# ---------------------------------------------------------------------------
# Joint: servo + bracket, parameterized by output axis
# ---------------------------------------------------------------------------

command HIP_YAW_JOINT(x: float, y: float, z: float) -> solid:
    # Hip yaw: servo shaft vertical (+Z), body below
    let servo: solid = translate(XL430_ENVELOPE(), x, y, z)
    emit servo

command HIP_ROLL_JOINT(x: float, y: float, z: float) -> solid:
    # Hip roll: servo shaft along +X, body offset
    let servo: solid = rotate(XL430_ENVELOPE(), 0.0, 90.0, 0.0)
    emit translate(servo, x, y, z)

command HIP_PITCH_JOINT(x: float, y: float, z: float) -> solid:
    # Hip pitch: servo shaft along +Y
    let servo: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    emit translate(servo, x, y, z)

command KNEE_PITCH_JOINT(x: float, y: float, z: float) -> solid:
    # Knee pitch: servo shaft along +Y
    let servo: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    emit translate(servo, x, y, z)

command ANKLE_PITCH_JOINT(x: float, y: float, z: float) -> solid:
    # Ankle pitch: servo shaft along +Y
    let servo: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    emit translate(servo, x, y, z)

command ANKLE_ROLL_JOINT(x: float, y: float, z: float) -> solid:
    # Ankle roll: servo shaft along +X
    let servo: solid = rotate(XL430_ENVELOPE(), 0.0, 90.0, 0.0)
    emit translate(servo, x, y, z)

# ---------------------------------------------------------------------------
# Structural links between joints
# ---------------------------------------------------------------------------

command THIGH_LINK() -> solid:
    # Simplified thigh link: box spanning hip pitch to knee pitch
    let link: solid = box(28.0, 20.0, THIGH_LENGTH_Z)
    emit translate(link, 0.0, 0.0, THIGH_LENGTH_Z / 2.0)

command SHIN_LINK() -> solid:
    # Simplified shin link: box spanning knee pitch to ankle pitch
    let link: solid = box(24.0, 18.0, SHIN_LENGTH_Z)
    emit translate(link, 0.0, 0.0, SHIN_LENGTH_Z / 2.0)

command FOOT_PLATE() -> solid:
    # Flat foot plate with ankle roll servo mounted above
    let plate: solid = box(40.0, 60.0, 8.0)
    emit translate(plate, 0.0, 0.0, -4.0)

# ---------------------------------------------------------------------------
# Full left leg assembly (zero pose)
# ---------------------------------------------------------------------------

command LEFT_LEG_ZERO_POSE() -> solid:
    # Build the leg chain from torso mount down to foot, all at zero joint angles.
    # The chain is built bottom-up so each joint sits at the distal end of the
    # previous link.

    # Hip yaw mount point (at torso interface, offset from midline)
    let hip_yaw: solid = HIP_YAW_JOINT(0.0, HIP_OFFSET_Y, 0.0)

    # Hip roll: directly below hip yaw (compact stack)
    let hip_roll: solid = HIP_ROLL_JOINT(0.0, HIP_OFFSET_Y, -18.0)

    # Hip pitch link + servo
    let hip_pitch: solid = HIP_PITCH_JOINT(0.0, HIP_OFFSET_Y, -HIP_LENGTH_X - 18.0)
    let thigh: solid = translate(THIGH_LINK(), 0.0, HIP_OFFSET_Y, -HIP_LENGTH_X - 18.0)

    # Knee pitch servo at the end of the thigh
    let knee_pitch: solid = KNEE_PITCH_JOINT(0.0, HIP_OFFSET_Y, -HIP_LENGTH_X - 18.0 - THIGH_LENGTH_Z)
    let shin: solid = translate(SHIN_LINK(), 0.0, HIP_OFFSET_Y, -HIP_LENGTH_X - 18.0 - THIGH_LENGTH_Z)

    # Ankle pitch at the end of the shin
    let ankle_pitch: solid = ANKLE_PITCH_JOINT(
        0.0, HIP_OFFSET_Y,
        -HIP_LENGTH_X - 18.0 - THIGH_LENGTH_Z - SHIN_LENGTH_Z
    )

    # Ankle roll + foot plate at the bottom
    let ankle_roll: solid = ANKLE_ROLL_JOINT(
        0.0, HIP_OFFSET_Y,
        -HIP_LENGTH_X - 18.0 - THIGH_LENGTH_Z - SHIN_LENGTH_Z - 18.0
    )
    let foot: solid = translate(FOOT_PLATE(), 0.0, HIP_OFFSET_Y,
        -HIP_LENGTH_X - 18.0 - THIGH_LENGTH_Z - SHIN_LENGTH_Z - ANKLE_HEIGHT)

    emit compound(
        hip_yaw, hip_roll, hip_pitch, thigh,
        knee_pitch, shin, ankle_pitch, ankle_roll, foot
    )

# ---------------------------------------------------------------------------
# Right leg: mirror of left about XZ plane (Y → -Y)
# ---------------------------------------------------------------------------

command RIGHT_LEG_ZERO_POSE() -> solid:
    let left: solid = LEFT_LEG_ZERO_POSE()
    emit mirror(left, vector(0.0, 1.0, 0.0))

# ---------------------------------------------------------------------------
# Parametric leg (accepts override parameters)
# ---------------------------------------------------------------------------

command LEFT_LEG_PARAMETRIC(
    hip_offset_y: float,
    hip_length_x: float,
    thigh_length_z: float,
    shin_length_z: float,
    ankle_height: float
) -> solid:
    # Placeholder for a fully parametric leg that accepts segment lengths.
    # The zero-pose version above uses the module-level params; this entry
    # point exists so the build tools can sweep dimensions.
    emit LEFT_LEG_ZERO_POSE()
