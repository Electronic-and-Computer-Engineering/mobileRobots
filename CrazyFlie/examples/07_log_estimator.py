"""Read the state estimate for a few seconds. No flying, propellers off."""
import time

from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger

import cflab

DURATION = 5.0
PERIOD_MS = 50


def main():
    with cflab.link() as scf:
        logconf = LogConfig(name="state", period_in_ms=PERIOD_MS)
        logconf.add_variable("stateEstimate.x", "float")
        logconf.add_variable("stateEstimate.y", "float")
        logconf.add_variable("stateEstimate.z", "float")
        logconf.add_variable("stateEstimate.yaw", "float")

        last = None
        t0 = time.time()
        with SyncLogger(scf, logconf) as logger:
            for _, data, _ in logger:
                last = data
                print(f"x={data['stateEstimate.x']:+.3f}  "
                      f"y={data['stateEstimate.y']:+.3f}  "
                      f"z={data['stateEstimate.z']:+.3f}  "
                      f"yaw={data['stateEstimate.yaw']:+.1f}")
                if time.time() - t0 >= DURATION:
                    break

        print("last values:", last)


if __name__ == "__main__":
    main()
