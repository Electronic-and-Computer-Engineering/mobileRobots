"""Fly a square at constant height, using hover setpoints."""
import time

import cflab

HEIGHT = 0.4
SPEED = 0.3             # m/s
SIDE_TIME = 2.0         # s per side -> side length = SPEED * SIDE_TIME
RATE_HZ = 50
DT = 1.0 / RATE_HZ


def move(scf, vx, vy, seconds, height=HEIGHT):
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_hover_setpoint(vx, vy, 0.0, height)
        time.sleep(DT)


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        cflab.unlock_thrust(scf)
        if not cflab.arm(scf):
            return

        try:
            move(scf, 0.0, 0.0, 2.0)            # climb and settle
            move(scf, SPEED, 0.0, SIDE_TIME)    # forward
            move(scf, 0.0, SPEED, SIDE_TIME)    # left
            move(scf, -SPEED, 0.0, SIDE_TIME)   # back
            move(scf, 0.0, -SPEED, SIDE_TIME)   # right
            move(scf, 0.0, 0.0, 1.0)            # settle
            for k in range(int(2.0 * RATE_HZ)): # down
                z = HEIGHT * (1.0 - k / (2.0 * RATE_HZ))
                scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, max(z, 0.05))
                time.sleep(DT)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
