"""Push Demo: the drone keeps its distance. Flow deck + Multiranger needed.

Hold a hand over the top sensor to land.
"""
from cflib.positioning.motion_commander import MotionCommander
from cflib.utils.multiranger import Multiranger

import cflab

HEIGHT = 0.4            # m
SPEED = 0.3             # m/s, how fast it backs away
TRIGGER = 0.4           # m, closer than this counts as "something is there"


def velocity_from(distance_m, sign):
    """One sensor -> one velocity component. Nothing there: no contribution."""
    if distance_m is None or distance_m > TRIGGER:
        return 0.0
    return sign * SPEED


def is_blocked(distance_m, limit=0.2):
    return distance_m is not None and distance_m < limit


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return
        if not cflab.has_deck(scf, "bcMultiranger"):
            print("No Multiranger deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        if not cflab.arm(scf):
            print("Not armed -- see section 2.4. Stopping.")
            return

        try:
            with MotionCommander(scf, default_height=HEIGHT) as mc:
                with Multiranger(scf) as ranger:
                    print("Flying. Hold a hand over the top sensor to land.")
                    keep_flying = True
                    while keep_flying:
                        vx = velocity_from(ranger.front, -1.0) \
                             + velocity_from(ranger.back, +1.0)
                        vy = velocity_from(ranger.right, +1.0) \
                             + velocity_from(ranger.left, -1.0)

                        mc.start_linear_motion(vx, vy, 0.0)

                        if is_blocked(ranger.up):
                            keep_flying = False
            print("landed")
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
