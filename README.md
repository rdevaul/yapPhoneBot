# yapPhoneBot

A procedural CAD re-implementation of the
[PhoneBot](https://phonebot.dev/) humanoid robot using
[yapCAD](https://github.com/rdevaul/yapCAD).

PhoneBot is a low-cost (~$400), open humanoid robot platform that reuses a
commodity smartphone as its primary sensing and computing unit. The original
mechanical design is released under CC BY-NC 4.0; this repository is an
independent yapCAD DSL re-implementation, licensed MIT.

**v0.1 is a pre-alpha engineering prototype.** Geometry and kinematics are
under active validation and must not yet be treated as a production-ready
mechanical design.

## Robot overview

| Spec         | Value                     |
|--------------|---------------------------|
| Height       | 48.3 cm                   |
| Mass         | 1.8 kg (incl. phone)      |
| DoF          | 13 (6 per leg + 1 torso)  |
| Actuators    | DYNAMIXEL XL430-W250-T    |
| Cost         | ~$400 (excl. phone)       |

## Coordinate convention

+X forward, +Y left, +Z up — matching the phonebot.dev control-policy datums
so that kinematic parameters map directly onto the existing locomotion
policies. All joint axes follow the original PhoneBot URDF / DH parameters.

## Repository layout

```
designs/          yapCAD DSL source of record
src/yaphonebot/   kinematics, validation, tooling
tests/            pytest suite (geometry, mates, kinematics)
bom/              procurement catalog (JSON) + generated CSVs
docs/             design, fabrication, fit-validation notes
tools/            build_ycpkg.py, STL comparison, fit coupons
renders/          preview images
reference/stl/    original PhoneBot STL files (download from phonebot.dev)
```

## Development environment

```bash
conda env create -f environment.yml
conda activate yaphonebot
python -m pip install -e '.[test]'
```

Run the test suite:

```bash
pytest -m "not visual and not expensive_geometry"
```

## Reference STL files

The original PhoneBot printable STL files are available from the
[phonebot.dev](https://phonebot.dev/) download page (CC BY-NC 4.0). Place
them in `reference/stl/` for the geometry-comparison tests:

```bash
# After downloading from phonebot.dev:
cp ~/Downloads/phonebot_parts/*.stl reference/stl/
```

The comparison tests validate Hausdorff distance and volume overlap between
DSL-generated meshes and the reference STLs.

## Generate the package

```bash
python tools/build_ycpkg.py
```

Output: `build/yaphonebot-0.1.0.ycpkg/`

## License

MIT — see [LICENSE](LICENSE).

The PhoneBot mechanical design by the original anonymous authors is released
under CC BY-NC 4.0. This repo is an independent procedural re-implementation
using yapCAD, not a derivative of the original CAD files. Attributed with
thanks.
