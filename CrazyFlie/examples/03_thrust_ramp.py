"""Thrust ramp on the bench. PROPELLERS OFF."""
import time

import cflab

RATE_HZ = 50
DT = 1.0 / RATE_HZ

THRUST_START = 8000
THRUST_STEP = 2000
THRUST_MAX = 22000
HOLD_TIME = 1.0


def send_for(scf, roll, pitch, yawrate, thrust, seconds):
    """Send one setpoint repeatedly -- the firmware needs the stream."""
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_setpoint(roll, pitch, yawrate, thrust)
        time.sleep(DT)


def ramp(scf):
    thrust = THRUST_START
    while thrust <= THRUST_MAX:
        print("thrust =", thrust)
        send_for(scf, 0.0, 0.0, 0.0, thrust, HOLD_TIME)
        thrust += THRUST_STEP

    thrust -= 2 * THRUST_STEP          # do not hold the top twice
    while thrust >= THRUST_START:
        print("thrust =", thrust)
        send_for(scf, 0.0, 0.0, 0.0, thrust, HOLD_TIME)
        thrust -= THRUST_STEP


def main():
    with cflab.link() as scf:
        try:
            cflab.unlock_thrust(scf)
            if not cflab.arm(scf):
                print("Not armed -- see section 2.4. Stopping.")
                return
            ramp(scf)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
