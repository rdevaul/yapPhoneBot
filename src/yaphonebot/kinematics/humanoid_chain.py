"""
Forward kinematics for the PhoneBot humanoid leg chain.

Uses DH parameters to compute the foot pose given joint angles.
The parameters match the phonebot.dev datum convention so that
generated joint commands map directly onto existing control policies.
"""

import numpy as np
from typing import Tuple

# ---------------------------------------------------------------------------
# DH parameters (zero-pose baseline, in mm)
# ---------------------------------------------------------------------------
# Link | theta  | d      | a     | alpha
# -----+--------+--------+-------+-------
# hip_yaw  | q0   | L0     | 0     | 0
# hip_roll | q1   | 0      | 0     | +90°
# hip_pitch| q2   | 0      | L1    | -90°
# knee_pitch| q3  | 0      | L2    | 0
# ankle_pitch| q4 | 0      | L3    | 0
# ankle_roll | q5 | 0      | 0     | +90°

# Default segment lengths (mm) — match the reference CAD dimensions
DEFAULT_HIP_Z_OFFSET = 26.8    # hip yaw → hip roll cluster (HIP_LENGTH_X)
DEFAULT_THIGH_LENGTH = 89.5    # thigh link (THIGH_LENGTH_Z)
DEFAULT_SHIN_LENGTH = 82.4     # shin link (SHIN_LENGTH_Z)
DEFAULT_ANKLE_HEIGHT = 44.0    # ankle cluster → foot sole (ANKLE_HEIGHT)


def _dh_transform(
    theta: float, d: float, a: float, alpha: float
) -> np.ndarray:
    """Standard DH homogeneous transform."""
    ct = np.cos(theta)
    st = np.sin(theta)
    ca = np.cos(alpha)
    sa = np.sin(alpha)
    return np.array([
        [ct, -st * ca,  st * sa, a * ct],
        [st,  ct * ca, -ct * sa, a * st],
        [0,   sa,       ca,      d],
        [0,   0,        0,       1],
    ])


def leg_forward_kinematics(
    q: np.ndarray,
    side: int = 1,
    hip_z: float = DEFAULT_HIP_Z_OFFSET,
    thigh: float = DEFAULT_THIGH_LENGTH,
    shin: float = DEFAULT_SHIN_LENGTH,
    ankle_h: float = DEFAULT_ANKLE_HEIGHT,
) -> np.ndarray:
    """
    Compute the foot homogeneous transform for one leg.

    Args:
        q: array of 6 joint angles [rad], ordered
           [hip_yaw, hip_roll, hip_pitch, knee_pitch, ankle_pitch, ankle_roll]
        side: +1 for left leg, -1 for right leg
        hip_z: vertical offset from hip yaw to hip roll joint
        thigh: hip pitch to knee pitch link length
        shin: knee pitch to ankle pitch link length
        ankle_h: ankle pitch to foot sole height

    Returns:
        4×4 homogeneous transform from hip yaw base to foot sole.
    """
    q = np.asarray(q, dtype=float)
    assert q.shape == (6,), "Expected 6 joint angles"

    # Offset the hip yaw joint laterally for left/right
    base = np.eye(4)
    base[1, 3] = side * 52.5  # HIP_OFFSET_Y from DSL

    # Each DH frame: angles offset by -pi/2 to match the physical zero pose
    T = base.copy()

    # Hip yaw: rotation about Z
    T = T @ _dh_transform(q[0], -hip_z, 0, 0)

    # Hip roll: rotation about X (alpha = +90° reorients)
    T = T @ _dh_transform(q[1], 0, 0, np.pi / 2)

    # Hip pitch: rotation about Y, link length = thigh offset
    T = T @ _dh_transform(q[2] - np.pi / 2, 0, thigh, -np.pi / 2)

    # Knee pitch: rotation about Y
    T = T @ _dh_transform(q[3], 0, shin, 0)

    # Ankle pitch: rotation about Y
    T = T @ _dh_transform(q[4], 0, 0, 0)

    # Ankle roll: rotation about X, offset to foot sole
    T = T @ _dh_transform(q[5], -ankle_h, 0, np.pi / 2)

    return T


def both_legs_forward_kinematics(
    q_left: np.ndarray,
    q_right: np.ndarray,
    **kwargs,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute foot transforms for both legs simultaneously.

    Returns (T_left, T_right).
    """
    T_l = leg_forward_kinematics(q_left, side=1, **kwargs)
    T_r = leg_forward_kinematics(q_right, side=-1, **kwargs)
    return T_l, T_r
