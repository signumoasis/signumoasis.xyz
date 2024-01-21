+++
title = "Peer to Peer (P2P) API"
description = "A detailed explanation of the peer to peer API."
date = 2024-01-01T00:00:00+00:00
updated = 2024-01-01T00:00:00+00:00
draft = true
weight = 10
sort_by = "weight"
template = "docs/page.html"

[extra]
toc = true
top = false
+++

## Basics

The P2P API consists of a single endpoint that accepts an HTTP POST request
containing a specifically structured JSON body. All information is passed through
this single endpoint. The endpoint _always_ returns a `200 OK` response, but if the
request is incorrect, the response body will be empty. This is _not_ correct HTTP API
design at all, but it is what the node does.

Here is an example request that gets a list of peers the node knows about.

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json

{
    "protocol": "B1",
    "requestType": "getPeers",
}
```

The above example is the minimum required to communicate with the node's P2P API.
This request is modeled as a raw HTTP request, so it will need to be adapted to
the programming language in use. Let's break it down.

* The request must be an HTTP 1.1 POST request.
* The `host` should be the address of the node the software wants to communicate
with and is required.
* Request Headers
  * The `User-Agent` MUST be `BRS/` followed by a valid version. Valid versions are
any version the node you're communicating with will accept. In practice, the node's
current version or later, and one version older, are valid. _NOTE: The node will not
respond without this header correctly set._
  * The `Connection` header is not required, but it is good practice. It lets the node's webserver
know that it is safe to close the connection after sending a response, and should not expect to
receive any further data from the client. It is unknown whether the node handles any option
except `close` for this header.
* Request Body
  * The request body is required to be a top-level JSON object. That is, it must begin and end
  with `{}`.
  * The root object must contain the `protocol` field with the case-sensitive value `B1`. No other
  protocol version exists and the node will not respond with information if this is incorrect.
  * The root object must contain the `requestType` field. This field defines the information
  being requested and can be thought of as the true 'endpoint' when comparing to a REST API.
  Valid request types are:
    * `addPeers`
    * `getCumulativeDifficulty`
    * `getInfo`
    * `getMilestoneBlockIds`
    * `getNextBlockIds`
    * `getBlocksFromHeigt`
    * `getNextBlocks`
    * `getPeers`
    * `getUnconfirmedTransactions`
    * `processBlock`
    * `processTransactions`

## Request Types / Virtual Endpoints

All request types will return a single root JSON object containing the information requested
or data in response to a request for the node to process something.

### addPeers

### getCumulativeDifficulty

### getInfo

Returns basic information about the node.

* `announcedAddress`: the configured address for the node; either an IP:port or host:port combination
* `application`: always 'BRS' for the Signum node.
* `version`: the node software version.
* `platform`: the configured platform field. Likely to be the Signum address of the node runner
or, by default, the string 'PC'.
* `shareAddress`: true or false. Indicates whether the client should share the queried node's address
to other nodes.
* `networkName`: the name of the network this node is running on. 'Signum' for the main Signum
network. 'TestNet' otherwise.

Example:

```json
{
    "announcedAddress": "p2p.signumoasis.xyz:80",
    "application": "BRS",
    "version": "v3.8.0",
    "platform": "S-C9TD-24WW-RUD3-FGHVJ",
    "shareAddress": true,
    "networkName": "Signum"
}
```

### getMilestoneBlockIds

### getNextBlockIds

### getBlocksFromHeigt

### getNextBlocks

### getPeers

Returns a list of peers the queried node knows about that it is allowed to share.

* `peers`: a JSON array of strings containing IP:port or host:port combinations.

Example:

```json
{
    "peers": [
        "158.69.63.213",
        "5.161.75.89",
        "157.90.168.219",
        "canada.signum.network:8123",
        "us-east.signum.network:8123",
        "europe.signum.network:8123",
    ]
}
```

### getUnconfirmedTransactions

### processBlock

### processTransactions
