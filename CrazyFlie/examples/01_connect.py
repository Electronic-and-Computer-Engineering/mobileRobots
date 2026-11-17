"""Open a link to the drone, print what it says, close it again."""
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"      # see chapter 1, section 1.7


def main():
    cflib.crtp.init_drivers()

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache="./cache")) as scf:
        print("Connected to", URI)

        battery = scf.cf.param.get_value("pm.batteryLevel")
        print("Battery level:", battery, "%")

        time.sleep(2.0)

    print("Disconnected")


if __name__ == "__main__":
    main()
