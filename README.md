# FlightTracker

![Real-World Event Sourcing Book Cover](./cover.jpg)

This is a demo project to present some learnings from the Book "Real-World Event Sourcing" from Kevin Hoffman.

## Contents of this project

A flight tracker for the Hamburg area.

### Commands

- Ingest snapshot

### Events

- Flight spotted
- Flight updated
- Flight left

### Injector

Fetches new API responses every 10s

#### Data

Aircraft Data from [`https://adsb.fi/`](https://adsb.fi/) 25NM from Hamburg. Request limit 1 Req/s

```bash
curl -Ss https://opendata.adsb.fi/api/v2/lat/53.551086/lon/9.993682/dist/25 | jq '.aircraft[]'
```

```jsonc
[
   {
     "hex": "484b90",
     "flight": "KLM49F",
     "desc": "BOEING 737-700",
     "lat": 53.583721,
     "lon": 9.336682,
   },
  // ...
]
```

### Projections

This demo has only one projection which calculates a statistic for the count of different aircraft models.

```elixir
%{
  "AIRBUS A-319" => 12,
  "AIRBUS A-320neo" => 2,
  "AIRBUS A-321" => 3,
  ...
  "unknown" => 23
}
```

### Notifiers

Notifies us about newly spotted Airbus Planes

```
13:33:25.290 [info] AIRBUS A-321neo flight WZZ6096 spotted! ICAO: 4d2425, LAT: 53.626979, LON: 10.001981
```
