// signal listening state machine
// ADSB signal construct, refer to ADSB_Vehicle class
type tADSBSignal = {
  icao: string;
  lat: number;
  lon: number;
  alt: number;
  squawk: string;
};

event eIntrusionDetected: tADSBSignal;
event eNoIntrusionDetected; // evenet 

// signal listener periodically listens to ADSB signals and determines
// whether the drone should be in avoid_adsb_mode or auto_mode

machine SignalListenerDecoder {
    // match the name of each of the intruding vehicle to the corresponding ADSB signal construct
    var intruding_aircrafts_info: map<string, tADSBSignal>;

    var avoid_adsb_mode_machine: AvoidADSBMode;
    var auto_mode_machine: AutoMode;

    start state SignalMonitoring {
        // initialize the state machines for the avoidADSB mode and auto mode
        entry (avoid_adsb_mode_machine_local: AvoidADSB, auto_mode_machine_local: AutoMode) {
            avoid_adsb_mode_machine = avoid_adsb_mode_machine_local;
            auto_mode_machine = auto_mode_machine_local;
        }

        // here use foreign function that returns bool to 
        // determine if there's an intrusion
        is_intrusion_detected = detectingIntrusion();
        
        if (is_intrusion_detected) {
            intruding_aircrafts_info = receive_intruding_aircrafts_info();

            // broadcast the intrusion events to all available state machines
            send avoid_adsb_mode_machine, eIntrusionDetected, intruding_aircrafts_info;
            send auto_mode_machine, eIntrusionDetected, intruding_aircrafts_info;
        }
        else {
            // broadcast the no intrusion events to all available state machines
            send avoid_adsb_mode_machine, eNoIntrusionDetected;
            send auto_mode_machine, eNoIntrusionDetected;
        }
        goto SignalMonitoring;
    }
}