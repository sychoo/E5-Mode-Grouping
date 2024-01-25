// Thu Jan 25 17:28:37 EST 2024
// waypoint following mode (auto mode)
// waypoint consists of latitude, longitude, and altitude

type tWaypoint = {
    lon: float;
    lat : float;
    alt : float;
};

machine AutoMode {
    var current_waypoint: tWaypoint;
    var signal_to_waypoint: tVelocityVector;

    // monitor aircraft intrusion, 
    // if intrusion is not detected,
    // proceed to the next waypoint
    start state SignalMonitoring {
        on eNoIntrusionDetected do {
            goto RetrieveCurrentWaypoint;
        }
    }

    state RetrieveCurrentWaypoint {
        current_waypoint = get_current_waypoint();
        goto GenerateSignalToWaypoint;
    }

    state GenerateSignalToWaypoint {
        signal_to_waypoint = generate_signal_to_waypoint(current_waypoint);
        goto ActuatePolicyToReachWaypoint;
    }

    state ActuatePolicyToReachWaypoint {
        actuate_policy_to_reach_waypoint(signal_to_waypoint);
        is_mission_completed = is_mission_completed();

        if (is_mission_completed) then {
            goto Halt;
        } else {
            goto SignalMonitoring;
        }
    }

    state Halt {
        // halt the aircraft, hover in place
    }
}
