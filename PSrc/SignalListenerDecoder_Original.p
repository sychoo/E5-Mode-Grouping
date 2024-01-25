type tADSBSignal = {
  icao: string;
  lat: number;
  lon: number;
  alt: number;
  squawk: string;
};

event eIntrusionDetected: tADSBSignal;
event eAirspaceClear;

machine SignalListenerDecoder {
    
}