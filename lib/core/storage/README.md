# Cloud Storage Layer

## Overview

This module provides a provider-agnostic abstraction for cloud file storage
(upload, download URL retrieval, deletion). It follows the same architectural
discipline as `core/data/` — feature code depends on the abstract interface,
never on the concrete Firebase implementation.

## Classes

| Class | Role |
|---|---|
| `BaseStorageService` | Pure Dart abstract class. Defines the contract for `uploadFile`, `downloadUrl`, and `deleteFile`. Zero Firebase imports. |
| `FirebaseStorageService` | Concrete implementation backed by Firebase Cloud Storage. The **only** file in the codebase that imports `firebase_storage`. |

## DI Wiring

`cloud_storage_providers.dart` registers `FirebaseStorageService` against the
`BaseStorageService` interface via Riverpod. Feature code injects
`BaseStorageService` — never `FirebaseStorageService`.

## Storage Path Convention

Callers are responsible for constructing the storage path. The service does not
enforce any convention, but the recommended pattern is:

```
{collection}/{documentId}/{filename}
```

Examples:
- `avatars/userId123/profile.jpg`
- `documents/orderId456/receipt.pdf`

## File Validation

File size limits and MIME type validation are the **caller's responsibility**.
The service does not validate these — it forwards bytes to the storage provider
as-is.

## Upload Cancellation

Uploads will be cancellable via a cancellation mechanism wired in US-35. The
`BaseStorageService` interface supports an `onProgress` callback for tracking
upload progress (receives a `double` between 0.0 and 1.0).

## Swapping Providers

To replace Firebase Storage with S3, GCS, or another provider:

1. Create a new class implementing `BaseStorageService`.
2. Update the DI registration in `cloud_storage_providers.dart`.
3. Zero feature code changes required.
