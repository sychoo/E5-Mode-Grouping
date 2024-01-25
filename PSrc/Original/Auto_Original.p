// created by Simon Chu
// 2023-04-12 10:56:43

// purpose:
// fine grained modeling of waypoint following mode
// based on MAV_CMD_NAV_WAYPOINT command for MAVLink
// https://ardupilot.org/copter/docs/common-mavlink-mission-command-messages-mav_cmd.html#mav-cmd-nav-waypoint

// functionality:
// ArduPilot waypoint mode (auto mode) allow the drone to visit each waypoints
// and hover at each waypoints for a number of seconds before proceeding to the next waypoints


type tMissionComplete = (current_waypoint_index : int, number_of_waypoints : int);

event eMissionStart;
event eMissionComplete : tMissionComplete;

event eProceedToWaypoint;
event eHoverAtWaypoint;
event eAdvanceWaypoint;

event eWaypointModeless;

machine Waypoint
{
  // stores the total number of waypoints 
  // set by the test driver
  var number_of_waypoints : int;

  // stores a list of waypoints
  // store the current waypoint index
  var current_waypoint_index : int;

  // initialize the variables
  start state Init {
    entry (number_of_way_points : int) {
      current_waypoint_index = -1;
      number_of_waypoints = number_of_way_points;
      
      print format ("[Waypoint] Waypoint Mode Initialized");

      send this, eMissionStart;
      goto AdvanceWaypoint;
    }
  }

  // set the current waypoint or advance to the next waypoints
  state AdvanceWaypoint {
    // note that two events can trigger the same state depending on where 
    // the event are sent from
    on eMissionStart, eAdvanceWaypoint do {
      
      // advance the current waypoints to the next waypoints
      current_waypoint_index = current_waypoint_index + 1;

      print format ("[Waypoint] Current Waypoint Index = {0}", current_waypoint_index);

      send this, eProceedToWaypoint;
      goto ProceedToWaypoint;
    }
  }

  // go to the next waypoint
  state ProceedToWaypoint {
    on eProceedToWaypoint do {
      // TODO: implement the logic to proceed to the waypoints
      send this, eHoverAtWaypoint;
      goto HoverAtWaypoint;
    }
  }

  // hover
  state HoverAtWaypoint {
    on eHoverAtWaypoint do {
      // TODO: implement the delay logic for a number of seconds (countdown)

      // check if the current waypoint is the last waypoint
      if (current_waypoint_index == number_of_waypoints - 1) {
        send this, eMissionComplete, (current_waypoint_index = current_waypoint_index, number_of_waypoints = number_of_waypoints);
        goto MissionComplete;
      } else {
        send this, eAdvanceWaypoint;
        goto AdvanceWaypoint;
      }
    }
  }

  // complete the task
  state MissionComplete {
    on eMissionComplete do {
      print format ("[Waypoint] Mission completed. Current Waypoint Index = {0}, Number of Waypoints = {1}", current_waypoint_index, number_of_waypoints);

      send this, eWaypointModeless;
      goto Modeless;
    }
  }

  // the Modeless state allow the drone to switch to other mode
  state Modeless {
    on eWaypointModeless do {
      // FIXME: this is here to trigger an example bug.
      // assert false, "modeless";
    }
  }
} 