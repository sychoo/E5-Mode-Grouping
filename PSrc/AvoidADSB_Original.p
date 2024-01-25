// the avoidance mode is meant to be enabled always
event eAvoidStart;
event eIntrusionDetected;
event eAvoidManeuverComplete;
event eAvoidModeless;

machine Avoid
{
  var number_of_intruding_aircraft : int;

  start state Init {
    entry (number_of_intruding_aircraft_local: int) {
      // set the number of intruding aircraft
      number_of_intruding_aircraft = number_of_intruding_aircraft_local;

      send this, eAvoidStart;
      goto DetectingIntrusion;
    }
  }

  state DetectingIntrusion {
    on eAvoidStart, eAvoidManeuverComplete do {
      // start the avoidance maneuver
      send this, eIntrusionDetected;
      goto AvoidManeuver;
    }
  }

  state AvoidManeuver {
    on eIntrusionDetected do {
      // avoidance maneuver complete
      // decrement global counter
      number_of_intruding_aircraft = number_of_intruding_aircraft - 1;

      print format ("Avoidance maneuver proceeding. {0} intruding aircraft remaining.", number_of_intruding_aircraft);

      // keep manuveuring until all intruding aircraft are gone
      if (number_of_intruding_aircraft > 0) {
        send this, eAvoidManeuverComplete;
        goto DetectingIntrusion;
      } else {
        send this, eAvoidModeless;
        goto Modeless;
      }
    }
  }

  state Modeless {
    on eAvoidModeless do {
      // do nothing
    }
  }
}