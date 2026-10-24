module yaphonebot_leg

# PhoneBot leg kinematic chain (6 DoF per leg).
# J1 Hip yaw (Z), J2 Hip roll (X), J3 Hip pitch (Y),
# J4 Knee pitch (Y), J5 Ankle pitch (Y), J6 Ankle roll (X).
#
# Coordinate convention: +X forward, +Y left, +Z up.
# Matches reference STEP/GLB CAD dimensions:
#   Hip lateral offset Y = ±52.5 mm
#   Hip roll/pitch cluster center Z = -79.3 mm
#   Knee pitch center Z = -168.8 mm (thigh link span = 89.5 mm)
#   Ankle pitch/roll cluster center Z = -251.2 mm (shin link span = 82.4 mm)
#   Foot top mounting face Z = -260.0 mm, sole Z = -295.2 mm

use yaphonebot_servo as servo

# === Parametric constants ==================================================
command HIP_OFFSET_Y() -> float:
    emit 52.5

command HIP_LENGTH_X() -> float:
    emit 26.8

command THIGH_LENGTH_Z() -> float:
    emit 89.5

command SHIN_LENGTH_Z() -> float:
    emit 82.4

command ANKLE_HEIGHT() -> float:
    emit 44.0

# === Structural links (in local joint frame, matching reference STLs) ======
command THIGH_LINK() -> solid:
    # UpperLegLink in local hip-pitch frame (Z_hip = -79.3 -> Z_local = 0):
    # Side cheeks at Y = ±21.0 (thickness 4 mm, Y in [-23, -19] and [19, 23]),
    # spanning X=[7.7, 35.3] (27.6), Z=[-74.5, -1.0] (73.5)
    cheek_l: solid = translate(box(27.6, 4.0, 73.5), 21.5, 21.0, -37.75)
    cheek_r: solid = translate(box(27.6, 4.0, 73.5), 21.5, -21.0, -37.75)
    # Distal knee bracket (U-channel wrapping knee servo):
    # X=[7.7, 61.9] (54.2), Y=[-21.0, +21.0] (42.0), Z=[-81.5, -66.5] (15.0)
    knee_box: solid = translate(box(54.2, 42.0, 15.0), 34.8, 0.0, -74.0)
    knee_cut: solid = translate(box(56.0, 34.0, 12.0), 34.8, 0.0, -71.0)
    knee_brkt: solid = difference(knee_box, knee_cut)
    # Angled transition gusset at Z=[-67.0, -54.0], X=[35.3, 52.0]
    gusset_box: solid = translate(box(17.0, 42.0, 13.0), 43.5, 0.0, -60.5)
    gusset_cut: solid = translate(box(19.0, 34.0, 15.0), 36.0, 0.0, -60.5)
    gusset: solid = difference(gusset_box, gusset_cut)
    emit union(union(cheek_l, cheek_r), union(knee_brkt, gusset))

command SHIN_LINK() -> solid:
    # LowerLegLink in local knee-pitch frame (Z_knee = -168.8 -> Z_local = 0):
    # Side cheeks at Y = ±21.0 (thickness 4 mm, Y in [-23, -19] and [19, 23]),
    # spanning X=[8.8, 33.8] (25.0), Z=[-81.4, +11.0] (92.4)
    cheek_l: solid = translate(box(25.0, 4.0, 92.4), 21.3, 21.0, -35.2)
    cheek_r: solid = translate(box(25.0, 4.0, 92.4), 21.3, -21.0, -35.2)
    # Rear C-channel web spanning X=[2.8, 9.6] (6.8), Y=[-23.0, +23.0] (46.0), Z=[-52.0, -10.0] (42.0)
    bridge: solid = translate(box(6.8, 46.0, 42.0), 6.2, 0.0, -31.0)
    emit union(union(cheek_l, cheek_r), bridge)

command FOOT_PLATE() -> solid:
    # Foot in local ankle-base frame (Z_ankle_base = -260.0 -> Z_local = 0):
    # Sole plate: X=[-20.4, +89.6] (110.0), Y=[-30.0, +30.0] (60.0), Z=[-35.2, -26.2] (9.0)
    sole: solid = translate(box(110.0, 60.0, 9.0), 34.6, 0.0, -30.7)
    # Front and rear arched mounting brackets to ankle roll servo:
    front_arch: solid = translate(box(14.0, 36.0, 26.2), 82.0, 0.0, -13.1)
    rear_arch: solid = translate(box(14.0, 36.0, 26.2), -2.0, 0.0, -13.1)
    emit union(sole, union(front_arch, rear_arch))

command HIP_CONNECTION() -> solid:
    # Hip dual-servo bracket (MotorConnection at X=-4.2 + IdlerServoBracket at X=+36.2):
    mc: solid = translate(box(38.1, 36.6, 46.2), -4.2, 0.0, 0.0)
    idler: solid = translate(box(10.8, 37.5, 46.0), 36.2, 0.0, 0.0)
    emit union(mc, idler)

command ANKLE_CONNECTION() -> solid:
    # Ankle dual-servo bracket (MotorConnection at X=+49.8 + IdlerServoBracket at X=+9.4):
    mc: solid = translate(box(38.1, 36.6, 46.2), 49.8, 0.0, 0.0)
    idler: solid = translate(box(10.8, 37.5, 46.0), 9.4, 0.0, 0.0)
    emit union(mc, idler)

# === Single leg ============================================================
command SINGLE_LEG(s: float) -> solid:
    ho: float = HIP_OFFSET_Y()
    z_hip: float = -79.3
    z_knee: float = -168.8
    z_ankle: float = -251.2
    z_foot: float = -260.0

    # Servo orientations matching reference CAD:
    # Hip yaw: vertical shaft (+Z), body rotated 90 deg in Z so long axis is along Y
    srv_yaw: solid = rotate(servo.XL430_ENVELOPE(), 0.0, 0.0, 90.0)
    # Roll servo: shaft along X, body long axis vertical (Z)
    srv_roll: solid = rotate(servo.XL430_ENVELOPE(), 0.0, 90.0, 0.0)
    # Pitch servo: shaft along Y, body long axis vertical (Z)
    srv_pitch: solid = rotate(servo.XL430_ENVELOPE(), 90.0, 90.0, 0.0)
    # Knee servo: shaft along Y, body long axis horizontal (X)
    srv_knee: solid = rotate(servo.XL430_ENVELOPE(), 90.0, 0.0, 0.0)

    # J1/J7 Hip yaw servo inside pelvis (centered at X=6.0, Y=s*40.5, Z=-24.0)
    hip_yaw: solid = translate(srv_yaw, 6.0, s * 40.5, -24.0)

    # J2/J8 Hip roll & J3/J9 Hip pitch coupled at Z = -79.3
    hip_roll: solid  = translate(srv_roll, -14.5, s * ho, z_hip)
    hip_pitch: solid = translate(srv_pitch, 22.8, s * ho, z_hip)
    hip_brkt: solid  = translate(HIP_CONNECTION(), 0.0, s * ho, z_hip)

    # UpperLegLink (thigh) extending from hip_pitch (Z = -79.3) down to knee (Z = -168.8)
    thigh: solid = translate(THIGH_LINK(), 0.0, s * ho, z_hip)

    # J4/J10 Knee pitch servo at Z = -168.8
    knee_pitch: solid = translate(srv_knee, 34.8, s * ho, z_knee)

    # LowerLegLink (shin) extending from knee (Z = -168.8) down to ankle (Z = -251.2)
    shin: solid = translate(SHIN_LINK(), 0.0, s * ho, z_knee)

    # J5/J11 Ankle pitch & J6/J12 Ankle roll coupled at Z = -251.2
    ankle_pitch: solid = translate(srv_pitch, 22.8, s * ho, z_ankle)
    ankle_roll: solid  = translate(srv_roll, 60.1, s * ho, z_ankle)
    ankle_brkt: solid  = translate(ANKLE_CONNECTION(), 0.0, s * ho, z_ankle)

    # Foot mounted at Z = -260.0 (sole at Z = -295.2)
    foot: solid = translate(FOOT_PLATE(), 0.0, s * ho, z_foot)

    emit compound(
        hip_yaw, hip_roll, hip_pitch, hip_brkt, thigh,
        knee_pitch, shin, ankle_pitch, ankle_roll, ankle_brkt, foot
    )

command LEFT_LEG() -> solid:
    emit SINGLE_LEG(1.0)

command RIGHT_LEG() -> solid:
    emit SINGLE_LEG(-1.0)
