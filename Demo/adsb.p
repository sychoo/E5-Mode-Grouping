machine AvoidADSBMode {
    var avoidance_action_parameter : int;
    var intruding_aircrafts_info   : tADSBSignal;
    var resolution_signal          : tVelocityVector;
    var current_waypoint_info      : tWaypoint;
    
    start state SignalMonitoring {
        on eIntrusionDetected do (
             intruding_aircrafts_info_local : tADSBSignal, 
             current_waypoint_info          : tWaypoint) {
                intruding_aircrafts_info = intruding_aircrafts_info_local;
                goto SelectingParameter;
        }
    }
  
    state SelectingParameter {
        AVD_F_ACTION_PARAM = selecting_avd_f_action_param(
                            current_waypoint_info, 
                            intruding_aircrafts_info);
        goto GenerateResolutionSignal;
    }
  
    state GenerateResolutionSignal {
        resolution_signal = generate_resolution_signal_modified(
                        intruding_aircrafts_info, 
                        AVD_F_ACTION_PARAM);
        goto ActuateResolutionSignal;
    }
  
    state ActuateResolutionSignal {
        actuate_resolution_signal(resolution_signal);
        goto SignalMonitoring;
    }
}


