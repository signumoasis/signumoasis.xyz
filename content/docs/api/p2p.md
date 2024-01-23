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
Content-Length: 58

{
    "protocol": "B1",
    "requestType": "getPeers"
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
  * The `Content-Type` header indicates to the node that it should parse the body as JSON. This
  is required to always be `application/json`.
  * The `Content-Length` header tells the node how long the body is, in bytes. This should be
  calculated just prior to sending the request. It is required.
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

Requests that the queried node add the supplied peers to its own database. Allows nodes to
proactively share nodes.

Returns an empty JSON root object.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 86

{
    "protocol": "B1",
    "requestType": "addPeers",
    "peers":["127.0.0.1"]
}
```

Example curl Request:

```bash
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "addPeers",
    "peers":["127.0.0.1"]
}'
```

Example Response:

```json
{}
```

### getCumulativeDifficulty

Returns the latest cumulative difficulty of the chain. Cumulative Difficulty is the result of
a calculation and allows the node to shift to a correct chain if there is a fork. The chosen
behavior to identify the correct chain is to seek the chain with the highest cumulative difficulty.

The calculation is:

```math
previous_cumulative_difficulty + (18446744073709551616 / base_target)
```

_NOTE: It is unknown why this number was chosen as a constant_.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 73

{
    "protocol": "B1",
    "requestType": "getCumulativeDifficulty"
}
```

Example curl Request:

```bash
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "getCumulativeDifficulty"
}'
```

Response Fields:

* `cumulativeDifficulty` the current cumulative difficulty.
* `blockchainHeight` this represents the number of blocks forged since the start of the chain.

Example Response:

```json
{
    "cumulativeDifficulty": "156571904172004726847",
    "blockchainHeight": 1236261
}
```

### getInfo

Returns basic information about the node.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 216

{
    "protocol": "B1",
    "requestType": "getInfo",
    "announcedAddress": "nodomain.com:8123",
    "application": "BRS",
    "version": "3.8.0",
    "platform": "Postman Test",
    "shareAddress": false
}
```

Example curl Request:

```bash
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "getInfo",
    "announcedAddress": "nodomain.com:8123",
    "application": "BRS",
    "version": "3.8.0",
    "platform": "Postman Test",
    "shareAddress": false
}'
```

Response Fields:

* `announcedAddress` the configured address for the node; either an IP:port or host:port combination
* `application` always 'BRS' for the Signum node.
* `version` the node software version.
* `platform` the configured platform field. Likely to be the Signum address of the node runner
or, by default, the string 'PC'.
* `shareAddress` true or false. Indicates whether the client should share the queried node's address
to other nodes.
* `networkName` the name of the network this node is running on. 'Signum' for the main Signum
network. 'TestNet' otherwise.

Example Response:

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

Gets the latest common block ids between the requesting node and the target node.
The behavior of this endpoint differs depending on whether or not the requesting
node has already located a common milestone block.

If it has _not yet_ found a common milestone, it will include the field `lastBlockId` in
the request to the target node. This will ask the target node to return up to 10 block IDs,
beginning with the top of its chain and skipping backwards by 10 blocks at at time. This
will cover 100 blocks of the target node's chain.

If it already has found a milestone block id, it will instead include the field
`lastMilestoneBlockId` in the request to the target node.
**NOTE: VERIFY THIS AGAIN** This seems to increase the jump and search a greater range for a common milestone....but I'm not sure why. It can only happen if we get a common milestone that isn't the same block as our max height. If the target node is at block 100 and we're at block 89, the first search with `lastBlockId` should count back by 10s, giving a common block of 80, but the second search looks to count backwards by 20s. I think it should be counting from 80 upward by a smaller jump, or from the chain height down to 80 by a smaller jump.

Description of request.

Returns an object.

#### Initial Request

Example HTTP Request for first request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 111

{
    "protocol": "B1",
    "requestType": "getMilestoneBlockIds",
    "lastBlockId": 8380252857853969990
}
```

Example curl Request for first request:

```bash
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "getMilestoneBlockIds",
    "lastBlockId": 8380252857853969990
}'
```

#### Subsequent Requests

Example HTTP Request for subsequent requests:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 123

{
    "protocol": "B1",
    "requestType": "getMilestoneBlockIds",
    "lastMilestoneBlockId": "13696763374077953626"
}
```

Example curl Request for subsequent requests:

```bash
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "getMilestoneBlockIds",
    "lastMilestoneBlockId": "13696763374077953626"
}'
```

Response Fields:

* `milestoneBlockIds` a JSON array of block IDs representing milestones.
* `last` a boolean; true if this is the last block in the target node's chain.
This field will only appear alongside an array of 1 block ID. This field does not
display false at all, but will not exist in the JSON object if the block returned
is not the final block in the chain.

Example Response when multiple milestones exist:

```json
{
    "milestoneBlockIds": [
        "6616678099081381479",
        "6616678099081381479",
        "17628736790110054844",
        "3765396070279574404",
        "17520803191368754192",
        "2365325381121334899",
        "7592344070605856558",
        "16978480488340389780",
        "7188559233614535978",
        "950191874937948114"
    ]
}
```

Example Response when multiple milestones exist (only when sending `lastBlockId`):

```json
{
    "milestoneBlockIds": [
        "950191874937948114"
    ],
    "last": true
}
```

### getNextBlockIds

Description of request.

Returns an object.

Example HTTP Request:

```http

```

Example curl Request:

```bash

```

Response Fields:

Example Response:

```json

```

### getBlocksFromHeigt

Description of request.

Returns an object.

Example HTTP Request:

```http

```

Example curl Request:

```bash

```

Response Fields:

Example Response:

```json

```

### getNextBlocks

Description of request.

Returns an object.

Example HTTP Request:

```http

```

Example curl Request:

```bash

```

Response Fields:

Example Response:

```json

```

### getPeers

Returns a list of peers the queried node knows about that it is allowed to share.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: us-east.signum.network:8123
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 58

{
    "protocol": "B1",
    "requestType": "getPeers"
}
```

Example curl Request:

```bash
curl --location 'http://us-east.signum.network:8123' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "getPeers"
}'
```

Response Fields:

* `peers` a JSON array of strings containing IP:port or host:port combinations.

Example Response:

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

Description of request.

Returns an object.

Example HTTP Request:

```http

```

Example curl Request:

```bash

```

Response Fields:

Example Response:

```json

```

### processBlock

Description of request.

Returns an object.

Example HTTP Request:

```http

```

Example curl Request:

```bash

```

Response Fields:

Example Response:

```json

```

### processTransactions

Description of request.

Returns an object.

Example HTTP Request:

```http

```

Example curl Request:

```bash

```

Response Fields:

Example Response:

```json

```
