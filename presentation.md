# Event Sourcing in Elixir

![Real-World Event Sourcing Book Cover](./cover.jpg)

> Distribute, Evolve, and Scale Your Elixir Applications

### Topics

- What is event sourcing
- Read vs. Write Models
- Injectors and Notifiers
- Process Managers
- Commanded library
- Event Stores
- Testing
- Security
- Scaling

---

# Overview

```
Injector/ ──► Command ──► Aggregate
Client                      │
                            │ Event
                            ▼
                  +--------------------+
                  |  Event Stream      |
                  +--------------------+
                            │
           ┌────────────────┴─────────────────┐
           ▼                ▼                 ▼
      Rebuild          Projector          Notifier
    Aggregate        (read models)
```

---

## Aggregates

The state calculated from all events in the event store.
Validates commands against business rules and appends events to the event stream

## Event Stream

The data storage for all events

---

## Commands

Intent to change the system. Can be rejected or converted to an event.
A command can generate multiple events or different events depending on the state of the aggregate.

Examples:

- Withdraw money
- Change position

## Events

Describes something has happened. Can't ever be changed. Source of truth

Examples:

- Money withdrawn
- Position updated

---

## Projections

Read models to optimize for querying instead of calculating from the aggregate everytime

Examples:

- Account Balance
- Leaderboards

## Injectors

Injects new events from an external source. Cannot depend on internal commands/events

## Notifiers

Handles on an internal event. Can read from projections and generate side effects

---

# What we are building today

A flight tracker for the Hamburg area.

## Commands

- Ingest snapshot

## Events

- Flight spotted
- Flight updated
- Flight left

---

## Injector

Fetches new API responses every 10s

### Data

Aircraft Data from [`https://adsb.fi/`](https://adsb.fi/) 25NM from Hamburg. Request limit 1 Req/s

```bash
curl -Ss https://opendata.adsb.fi/api/v2/lat/53.551086/lon/9.993682/dist/25 | jq '.aircraft[:1]'
```

```json
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

---

## Projections

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

---

## Notifiers

Notifies us about newly spotted Airbus Planes

```
13:33:25.290 [info] AIRBUS A-321neo flight WZZ6096 spotted! ICAO: 4d2425, LAT: 53.626979, LON: 10.001981
```

---

```
~~~figlet CODE
Code
~~~
```

---

# Link to repo

```
~~~qrencode -t ansiutf8 "https://github.com/kevinschweikert/flight_tracker"
QR Code
~~~
```

Thanks for listening!
