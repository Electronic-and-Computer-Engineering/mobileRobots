"""Turn on the spot: clockwise, then back."""
import time

import cflab

HEIGHT = 0.4
YAWRATE = 45.0          # deg/s, positive turns left
TURN_TIME = 2.0
RATE_HZ = 50
DT = 1.0 / RATE_HZ


def turn(scf, yawrate, seconds, height=HEIGHT):
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, yawrate, height)
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
            turn(scf, 0.0, 2.0)                 # climb and settle
            turn(scf, YAWRATE, TURN_TIME)       # one way
            turn(scf, 0.0, 1.0)
            turn(scf, -YAWRATE, TURN_TIME)      # and back
            turn(scf, 0.0, 1.0)
            for k in range(int(2.0 * RATE_HZ)):
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
