module yaphonebot_assembly

# Full PhoneBot assembly: torso + left leg + right leg.
#
# This file is the top-level DSL entry point that composes the
# individual modules into a complete robot in its zero (standing) pose.
#
# Coordinate convention: +X forward, +Y left, +Z up.
# Origin (0, 0, 0) is at the torso yaw joint center.
# Ground plane is at Z ≈ -HIP_LENGTH_X - THIGH - SHIN - ANKLE_HEIGHT.

# Include sub-modules (yapCAD resolves these by filename)
# yaphonebot_servo.dsl   → servo envelope primitives
# yaphonebot_leg.dsl     → leg kinematic chain
# yaphonebot_torso.dsl   → torso + phone/SBC/battery

# ---------------------------------------------------------------------------
# Full robot in zero pose
# ---------------------------------------------------------------------------

command PHONEBOT_ZERO_POSE() -> solid:
    let torso: solid = TORSO_ASSEMBLY()
    let left_leg: solid = LEFT_LEG_ZERO_POSE()
    let right_leg: solid = RIGHT_LEG_ZERO_POSE()

    emit compound(torso, left_leg, right_leg)

# ---------------------------------------------------------------------------
# Annotated assembly with named parts (for BOM generation)
# ---------------------------------------------------------------------------

instance left_leg: "yaphonebot_leg" at (0, 0, 0):
    mate hip_yaw_mount to torso.left_hip_yaw
    mate foot_to_ground to ground.z_zero

instance right_leg: "yaphonebot_leg" at (0, 0, 0):
    mate hip_yaw_mount to torso.right_hip_yaw
    mate foot_to_ground to ground.z_zero

instance torso: "yaphonebot_torso" at (0, 0, 0):
    mate ground_mount to chassis.top

# ---------------------------------------------------------------------------
# Mates and coupling graph
# ---------------------------------------------------------------------------

mate torso.left_hip_yaw {
    type: revolute
    axis: (0, 0, 1)          # Z-axis rotation for hip yaw
    location: (0, 50.0, 0)   # offset from midline
    range: [-90, 90]         # degrees, to be validated
}

mate torso.right_hip_yaw {
    type: revolute
    axis: (0, 0, 1)
    location: (0, -50.0, 0)
    range: [-90, 90]
}

mate torso.yaw_joint {
    type: revolute
    axis: (0, 0, 1)
    location: (0, 0, 0)
    range: [-90, 90]
}

mate leg.hip_roll {
    type: revolute
    axis: (1, 0, 0)          # X-axis rotation
    offset_from_parent: (0, 0, -18.0)
    range: [-45, 45]
}

mate leg.hip_pitch {
    type: revolute
    axis: (0, 1, 0)          # Y-axis rotation
    offset_from_parent: (0, 0, -HIP_LENGTH_X)
    range: [-90, 90]
}

mate leg.knee_pitch {
    type: revolute
    axis: (0, 1, 0)
    offset_from_parent: (0, 0, -THIGH_LENGTH_Z)
    range: [0, 135]          # knee only bends one way
}

mate leg.ankle_pitch {
    type: revolute
    axis: (0, 1, 0)
    offset_from_parent: (0, 0, -SHIN_LENGTH_Z)
    range: [-45, 45]
}

mate leg.ankle_roll {
    type: revolute
    axis: (1, 0, 0)
    offset_from_parent: (0, 0, -18.0)
    range: [-30, 30]
}

# Ground contact plane
mate ground.z_zero {
    type: fixed
    axis: (0, 0, 1)
    location: (0, 0, -266.0)  # approximate ground height in zero pose
}

# ---------------------------------------------------------------------------
# BOM metadata (per-part material / procurement class)
# ---------------------------------------------------------------------------

bom_part left_leg {
    material: "PETG"
    class: "make"
    printer: "FDM"
    estimated_mass_g: 150
}

bom_part right_leg {
    material: "PETG"
    class: "make"
    printer: "FDM"
    estimated_mass_g: 150
}

bom_part torso {
    material: "PETG"
    class: "make"
    printer: "FDM"
    estimated_mass_g: 200
}

bom_part servo {
    material: "COTS"
    class: "buy"
    part_number: "DYNAMIXEL-XL430-W250-T"
    quantity: 13
}
