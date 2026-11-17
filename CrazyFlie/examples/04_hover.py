"""Hover at a fixed height for a few seconds, then come down."""
import time

import cflab

HEIGHT = 0.4            # metres
HOVER_TIME = 5.0        # seconds
RATE_HZ = 50
DT = 1.0 / RATE_HZ


def hover(scf, height, seconds):
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, height)
        time.sleep(DT)


def descend(scf, height, seconds=2.0):
    """Walk the commanded height down to the floor instead of cutting thrust."""
    steps = int(seconds * RATE_HZ)
    for k in range(steps):
        z = height * (1.0 - k / steps)
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, max(z, 0.05))
        time.sleep(DT)


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        cflab.unlock_thrust(scf)
        if not cflab.arm(scf):
            print("Not armed -- see section 2.4. Stopping.")
            return

        try:
            hover(scf, HEIGHT, HOVER_TIME)
            descend(scf, HEIGHT)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
