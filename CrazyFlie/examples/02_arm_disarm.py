"""Arm the drone, read the supervisor state, disarm again. PROPELLERS OFF."""
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"


def show_state(scf, label):
    """Print every supervisor condition that is currently true."""
    states = scf.cf.supervisor.read_state_list()
    print(f"{label:9s} {states}")


def main():
    cflib.crtp.init_drivers()

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache="./cache")) as scf:
        show_state(scf, "before:")

        if not scf.cf.supervisor.can_be_armed:
            print("The drone says it cannot be armed. Battery? Standing level?")

        scf.cf.supervisor.send_arming_request(True)
        time.sleep(0.5)
        show_state(scf, "armed:")
        print("is_armed =", scf.cf.supervisor.is_armed)

        time.sleep(3.0)

        scf.cf.supervisor.send_arming_request(False)
        time.sleep(0.5)
        show_state(scf, "after:")


if __name__ == "__main__":
    main()
