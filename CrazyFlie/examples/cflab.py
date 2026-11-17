"""Shared helpers for the CrazyFlie lab. The URI lives here, and only here."""
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"      # Crazyflie 2.1 Brushless, chapter 1


def link(uri=None):
    """Open a link. Use it as:  with cflab.link() as scf: ..."""
    cflib.crtp.init_drivers()
    return SyncCrazyflie(uri or URI, cf=Crazyflie(rw_cache="./cache"))


def arm(scf, timeout=3.0):
    """Request arming and wait for the drone to confirm it.

    Returns True if the drone reported itself armed. On firmware too old to
    report, it returns False although the request did go out -- watch the
    motors in that case.
    """
    scf.cf.supervisor.send_arming_request(True)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if scf.cf.supervisor.is_armed:
            print("armed")
            return True
        time.sleep(0.1)
    print("not confirmed armed. State:", scf.cf.supervisor.read_state_list())
    return False


def disarm(scf):
    scf.cf.supervisor.send_arming_request(False)
    time.sleep(0.2)
    print("disarmed")


def unlock_thrust(scf):
    """Release the firmware's thrust lock.

    The first setpoint after connecting must carry thrust 0, otherwise the
    firmware keeps the motors locked and nothing you send afterwards has any
    effect.
    """
    scf.cf.commander.send_setpoint(0.0, 0.0, 0.0, 0)
    time.sleep(0.1)


def stop(scf):
    """Cut the setpoint stream, the way the firmware wants it cut."""
    scf.cf.commander.send_setpoint(0.0, 0.0, 0.0, 0)
    time.sleep(0.1)
    scf.cf.commander.send_stop_setpoint()
    scf.cf.commander.send_notify_setpoint_stop()


def has_deck(scf, name="bcFlow2"):
    """True if the named expansion deck was detected. bcFlow2, bcMultiranger."""
    try:
        return int(scf.cf.param.get_value(f"deck.{name}")) == 1
    except Exception:
        return False


def reset_estimator(scf):
    """Reset the Kalman estimator and let it settle. Do this before take-off."""
    scf.cf.param.set_value("kalman.resetEstimation", "1")
    time.sleep(0.1)
    scf.cf.param.set_value("kalman.resetEstimation", "0")
    time.sleep(2.0)
