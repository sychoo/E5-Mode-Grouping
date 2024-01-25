// avoid ADS-B mode state machine
type tResolutionSignal = {
  north: float;
  east: float;
  down: float;
};

// mode the avoid ADS-B mode
machine AvoidADSBMode {
  var AVD_F_ACTION_PARAM: int; // stores the fixed parameter for the avoidance maneuver
  var intruding_aircrafts_info: tADSBSignal; // stores the information about the intruding aircrafts
  var resolution_signal: tResolutionSignal; // stores the resolution signal

  // monitors whether there's an intrusion
  // only respond when there's an intrusion
  start state SignalMonitoring {
    on eIntrusionDetected do (intruding_aircrafts_info_local: tADSBSignal) {
      intruding_aircrafts_info = intruding_aircrafts_info_local;
      goto RetrieveParameter;
    }
  }

  state RetrieveParameter {
    // foreign function to retrieve the parameter
    AVD_F_ACTION_PARAM = retrieve_avd_f_action_param();
    goto GenerateResolutionSignal;
  }

  state GenerateResolutionSignal {
    // foreign function to generate the resolution signal
    resolution_signal = generate_resolution_signal(intruding_aircrafts_info, AVD_F_ACTION_PARAM);
    goto ActuateResolutionSignal;
  }

  state ActuateResolutionSignal {
    // foreign function to actuate the resolution signal
    actuate_resolution_signal(resolution_signal);
    goto SignalMonitoring;
  }
}