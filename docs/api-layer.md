# The API layer

Two backends sit behind the same repository interfaces: Supabase, and an
in-app demo backend. Which one the app uses is decided in `data/backend.dart`
and is invisible above it.

```
blocs
  └── repositories.dart        the interfaces the blocs depend on
        ├── remote/*.dart      Supabase, via supabase_flutter
        └── api/*.dart         HTTP, via Retrofit over Dio
              └── DemoBackend  a Dio interceptor answering in-process
```

## Why a Dio interceptor is the fake

`DemoBackend` is registered as an interceptor rather than mocked at the
repository level, so every layer above it — client, repositories, blocs,
widgets — runs exactly as it would against a real server. It holds mutable
state between calls, applies latency, and can be told to fail, so loading and
error paths are reachable without a network.

One detail there is load-bearing: it `reject`s any status of 400 or more
rather than `resolve`-ing it. `resolve` bypasses Dio's status validation, so a
401 would otherwise arrive at the caller looking like success — a wrong OTP
would have signed the user in.

## Why the wire types exist

`api_service.dart` declares the 22 endpoints; Retrofit generates the client.
Retrofit needs a `fromJson` on every return type, and it accepts neither
`List<dynamic>` nor `Map<String, dynamic>`:

* `List<dynamic>` crashes the generator.
* `Map<String, dynamic>` is worse — it writes the file and reports success,
  having emitted `dynamic.fromJson(...)`, which does not compile. Run the
  analyzer on generated code; a green build is not the same claim.

The usual answer is a second set of models from `json_serializable`. That was
deliberately **not** done here. The Supabase and HTTP repositories share one
set of parsers in `remote/mappers.dart`, and the demo backend serves the same
field names Supabase uses — one wire format, one set of parsers, two
transports. Generating a second set of models would have forked that and let
the two backends drift apart silently.

So `wire.dart` holds one small wrapper per payload, each a single call to the
existing mapper:

```dart
factory HotelWire.fromJson(Map<String, dynamic> json) =>
    HotelWire(hotelFromRow(json));
```

Typed returns for Retrofit, one parser still. Repositories unwrap `.value`.

If you add an endpoint: declare it in `api_service.dart`, add a wrapper in
`wire.dart` if it returns a body, run `dart run build_runner build`, and have
the repository call the generated method. Do not add a path string to a
repository, and do not generate models.

## What is not wired up

`ApiClient.live(baseUrl)` points the same generated client at a real HTTP
server. Nothing calls it: it is the seam for replacing the demo backend
without touching anything above `ApiClient`.

Retrofit and Dio carry traffic only on the demo path. In a build running
against Supabase they are compiled in but idle, because the Supabase
repositories use `supabase_flutter`'s own client.
