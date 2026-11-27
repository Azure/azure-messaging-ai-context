# How to Build Azure Watson Search URLs

The [Azure Watson portal](https://portal.watson.azure.com/) supports deep-link
search URLs that pre-populate the advanced-search filter, so you can hand a
colleague (or an investigation MCP/agent) a URL that lands directly on the
dumps you care about.

This page documents the URL grammar and gives templates for common Azure
Messaging investigation cases (Service Bus, Event Grid, Block Storage, geo
replication).

> **Access**: The Azure Watson portal is only reachable from SAW.
> URLs you build here are intended to be opened on a SAW device.

> **Agents**: if the `azure-watson` MCP is configured (for example in
> Azure-MessagingStore's `.mcp.json`), look up a known dump with
> `get_dump_metadata` (DumpUID) or a known failure with `get_failure_metadata`
> (failure hash or bucket ID) instead of building a URL. The MCP cannot search by
> cluster, role instance or PID; for that, build an advanced search URL and hand
> it to someone on SAW.

## URL Anatomy

Watson links come in three forms:

| Form                            | URL                                                                                        |
|---------------------------------|--------------------------------------------------------------------------------------------|
| Advanced search                 | `https://portal.watson.azure.com/?$filter=(<ODATA_FILTER>)&view=advancedsearch_b&range=<RANGE>` |
| Bucket (one failure signature)  | `https://portal.watson.azure.com/bucket?$filter=(<ODATA_FILTER>)`                          |
| Single dump                     | `https://portal.watson.azure.com/dump?dumpUID=<DumpUID>`                                   |

The rest of this page is about advanced search URLs:

| Component         | Purpose                                                                                   |
|-------------------|-------------------------------------------------------------------------------------------|
| `$filter`         | URL-encoded OData expression — the same grammar shown in the advanced search UI           |
| `view`            | `advancedsearch_b` for the advanced search experience                                     |
| `range`           | Optional coarse time scope: `day`, `week`, `month`, `quarter`. Many links omit it          |

If you set `range`, make it span your `ClientIngestTime` window: dumps whose
`ClientIngestTime` falls outside `range` are not shown, even if they match the filter.

## Filter Grammar (OData)

| Operator         | Meaning                                  | Example                                                          |
|------------------|------------------------------------------|------------------------------------------------------------------|
| `eq`             | equals                                   | `FailureInfo_FaultingProcess eq 'geo_replication_win_service.exe'` |
| `ne`             | not equals                               | `FailureInfo_FaultingProcessPID ne '0'`                          |
| `ge` / `le`      | greater/less than or equal               | `ClientIngestTime ge 2026-05-22T07:00:00.000Z`                   |
| `gt` / `lt`      | strictly greater/less than               | `ClientIngestTime lt 2026-05-23T00:00:00.000Z`                   |
| `and` / `or`     | boolean combine                          | `FailureInfo_FaultingProcess eq 'Fabric.exe' or FailureInfo_FaultingProcess eq 'FabricGateway.exe'` |
| `( ... )`        | grouping                                 | wraps the whole expression and any `or` sub-expressions          |

> **String values are single-quoted, timestamps are not.**
> A bare `2026-05-22T07:00:00.000Z` is a timestamp literal; `'PROD-SN3-AZ402'`
> is a string literal.

## Common Filter Fields

| Field                                | Notes                                                                                                                                       |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `ClientIngestTime`                   | When the dump was ingested into Watson. Use `ge`/`le` for the window. Format: `YYYY-MM-DDTHH:MM:SS.sssZ`                                    |
| `IdentityDictionary/ScaleUnit`       | Cluster name, e.g. `'PROD-SN3-AZ402'`. Path syntax with the `/` is required — `ScaleUnit` alone won't match.                                |
| `FailureInfo_FaultingProcess`        | Executable name including `.exe`. Examples: `'geo_replication_win_service.exe'`, `'Fabric.exe'`, `'block_storage_2_sf.exe'`.                |
| `RoleInstance`                       | SF role instance, e.g. `'backend_14'`. Watson indexes it **without** the leading underscore that ICM titles and MDM dimensions add: search `'Gateway_87'`, not `'_Gateway_87'`. |
| `FailureInfo_FaultingProcessPID`     | PID as a **string-quoted decimal**, e.g. `'19656'`. Quote it — numeric form doesn't always match.                                           |
| `FailureInfo_BucketId`               | Watson bucket ID, e.g. `'FAIL_FAST_FATAL_APP_EXIT_c0000409_...'`. Useful when you already know the bucket from a sibling dump.              |

## URL Encoding

Hand-built URLs must encode at minimum:

| Character | Encoded |
|-----------|---------|
| space     | `%20`   |
| `'`       | `%27`   |
| `(`       | `%28` (optional; the portal accepts unencoded parens) |
| `)`       | `%29` (optional) |

Operators (`eq`, `and`, `or`, `ge`, `le`), field paths (`IdentityDictionary/ScaleUnit`)
and timestamps do NOT need encoding.

> **Tip**: Build the URL in two steps — write the readable OData expression first,
> then encode spaces and quotes. Mistakes compound quickly if you encode while typing.

## Worked Examples

### Find dumps of a named process on a cluster

Use this when investigating a specific binary's crash on a specific cluster
(e.g., native geo replication service watchdog kill, EBS report-fault, broker
crash).

Readable filter:

```
ClientIngestTime ge 2026-05-22T07:00:00.000Z and
ClientIngestTime le 2026-05-23T00:00:00.000Z and
IdentityDictionary/ScaleUnit eq 'PROD-SN3-AZ402' and
FailureInfo_FaultingProcess eq 'geo_replication_win_service.exe'
```

Encoded URL (note `range=month` because the window crosses days):

```
https://portal.watson.azure.com/?$filter=(ClientIngestTime%20ge%202026-05-22T07:00:00.000Z%20and%20ClientIngestTime%20le%202026-05-23T00:00:00.000Z%20and%20IdentityDictionary/ScaleUnit%20eq%20%27PROD-SN3-AZ402%27%20and%20FailureInfo_FaultingProcess%20eq%20%27geo_replication_win_service.exe%27)&view=advancedsearch_b&range=month
```

### Find dumps of a specific RoleInstance + PID

Use this when correlating against a known stuck/crashed PID identified from
DGrep or Kusto. Strip the leading underscore from the RoleInstance.

Readable filter:

```
ClientIngestTime ge 2026-05-22T07:00:00.000Z and
ClientIngestTime le 2026-05-23T00:00:00.000Z and
IdentityDictionary/ScaleUnit eq 'PROD-SN3-AZ402' and
RoleInstance eq 'backend_14' and
FailureInfo_FaultingProcessPID eq '19656'
```

Encoded URL:

```
https://portal.watson.azure.com/?$filter=(ClientIngestTime%20ge%202026-05-22T07:00:00.000Z%20and%20ClientIngestTime%20le%202026-05-23T00:00:00.000Z%20and%20IdentityDictionary/ScaleUnit%20eq%20%27PROD-SN3-AZ402%27%20and%20RoleInstance%20eq%20%27backend_14%27%20and%20FailureInfo_FaultingProcessPID%20eq%20%2719656%27)&view=advancedsearch_b&range=month
```

### Find every dump on a role instance

Use this when you don't know which process crashed. Leave out
`FailureInfo_FaultingProcess`, filter on the role instance, and look at
`CrashProcess` in the results:

```
ClientIngestTime ge 2026-05-22T07:00:00.000Z and
ClientIngestTime le 2026-05-23T00:00:00.000Z and
IdentityDictionary/ScaleUnit eq 'PROD-SN3-AZ402' and
RoleInstance eq 'backend_14'
```

## Empty Results

An empty Watson search **does not** prove nothing went wrong:

- A stuck-then-recycled process may have been killed by Service Fabric without
  faulting (no dump produced).
- Watson ingest can lag; dumps from the last hour may not yet be queryable.
- Watson keeps dumps for 29 days from when they were created, then deletes them.
- `ClientIngestTime` is the **ingest** time, not the **crash** time. A dump
  from a crash 10 minutes before a `ClientIngestTime ge` lower bound may
  legitimately exist but be excluded. Widen the lower bound by an hour or two
  if you're hunting a specific event.

## Interpreting the Hit

The Watson detail panel surfaces these fields that matter for routing the next step:

| Field             | Meaning                                                                                                                |
|-------------------|------------------------------------------------------------------------------------------------------------------------|
| `DumpCrashTime`   | When the process actually died. Compare against your timeline — a crash that precedes a "stuck" signature means the stuck signature is downstream. |
| `CrashProcess`    | The executable that died.                                                                                              |
| `ErrorCode`       | The SEH code. Common values: `0xe0434352` = unhandled .NET (CLR) exception (open the dump in VS/WinDbg and run `!pe` to see the inner exception type and managed stack); `0xc0000005` = AV; `0xc0000409` = stack buffer overrun (almost always `abort()` from a failed assert, not a real buffer overrun); `0x80000003` = breakpoint (often a `__fastfail` or `Debugger.Break`). |
| `DumpUID`         | The unique dump identifier. Use this when handing the dump to someone else for debugging.                              |
| `CrashProcessPath`| Includes the SF code-package version segment — useful for confirming exactly which build was running.                  |

See also: [How to Debug an Azure Watson Crash Dump](https://msazure.visualstudio.com/One/_git/Azure-MessagingStore?path=/doc/wiki/dev/how_to_debug_azure_watson_crash_dump.md) (EBS repo)
for downloading symbols and opening dumps once you've found one.
