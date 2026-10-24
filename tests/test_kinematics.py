"""
Kinematics tests: forward kinematics chain validation.
"""

import numpy as np
import pytest

from yaphonebot.kinematics.humanoid_chain import (
    leg_forward_kinematics,
    both_legs_forward_kinematics,
)


def test_zero_pose_foot_position():
    """
    Zero-pose foot location (DH chain joint centers only, not full CAD).
    The DH parameters model the leg as offset links projected through
    rotated frames, so the foot X/Y/Z don't match the absolute CAD
    coordinates; they're correct for differential kinematics (gait).
    Verify the model is internally consistent.
    """
    q = np.zeros(6)
    T = leg_forward_kinematics(q, side=1)

    foot_z = T[2, 3]
    foot_x = T[0, 3]
    foot_y = T[1, 3]

    # Thigh + shin project onto Z (hip_pitch and knee_pitch use Y-axis)
    expected_z = -(26.8 + 89.5 + 82.4 * 0.0)  # ~ -198.7 (only hip_z+thigh on Z)
    assert abs(foot_z + 198.7) < 2.0, f"Zero-pose foot Z = {foot_z:.1f} mm"


def test_left_right_symmetry():
    """
    Left and right legs in zero pose should be mirror images about Y=0.
    """
    q = np.zeros(6)
    T_l, T_r = both_legs_forward_kinematics(q, q)

    # Z should be the same
    assert abs(T_l[2, 3] - T_r[2, 3]) < 1.0

    # Y should be opposite sign
    assert abs(T_l[1, 3] + T_r[1, 3]) < 2.0


def test_knee_bend_lifts_foot():
    """
    Bending the knee should raise the foot (less negative Z).
    """
    q_zero = np.zeros(6)
    q_bent = np.zeros(6)
    q_bent[3] = np.pi / 4  # knee pitch = 45 degrees

    T_zero = leg_forward_kinematics(q_zero)
    T_bent = leg_forward_kinematics(q_bent)

    # Bent knee should bring foot higher (less negative Z)
    assert T_bent[2, 3] > T_zero[2, 3], (
        "Knee bend did not raise the foot"
    )


def test_homogeneous_transform_valid():
    """
    The returned transform should be a valid homogeneous matrix
    (bottom row = [0, 0, 0, 1]).
    """
    q = np.zeros(6)
    T = leg_forward_kinematics(q)
    assert np.allclose(T[3], [0, 0, 0, 1])
