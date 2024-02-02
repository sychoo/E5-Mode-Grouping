// avoid ADS-B mode state machine
type tVelocityVector = {
  north: float;
  east: float;
  down: float;
};

// mode the avoid ADS-B mode
machine AvoidADSBMode {
  var AVD_F_ACTION_PARAM: int; // stores the fixed parameter for the avoidance maneuver
  var intruding_aircrafts_info: tADSBSignal; // stores the information about the intruding aircraft

  var resolution_signal: tVelocityVector; // stores the resolution signal

  // modified
  var current_waypoint_info: tWaypoint; // stores the current waypoint information
  
  // monitors whether there's an intrusion
  // only respond when there's an intrusion
  start state SignalMonitoring {
    on eIntrusionDetected do (intruding_aircrafts_info_local: tADSBSignal, current_waypoint_info: tWaypoint) {
      intruding_aircrafts_info = intruding_aircrafts_info_local;
      goto SelectingParameter;
    }
  }

  state SelectingParameter {
    // foreign function to retrieve the parameter
    
    // modified function
    // given the current waypoint information, and intruding aircrafts, selects a corresponding parameter to be actuated.
    AVD_F_ACTION_PARAM = selecting_avd_f_action_param(current_waypoint_info, intruding_aircrafts_info);
    goto GenerateResolutionSignal;
  }

  state GenerateResolutionSignal {
    // foreign function to generate the resolution signal
    resolution_signal = generate_resolution_signal_modified(intruding_aircrafts_info, AVD_F_ACTION_PARAM);
    goto ActuateResolutionSignal;
  }

  state ActuateResolutionSignal {
    // foreign function to actuate the resolution signal
    actuate_resolution_signal(resolution_signal);
    goto SignalMonitoring;
  }
}