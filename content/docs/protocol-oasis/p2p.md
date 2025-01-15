+++
title = "Peer to Peer (P2P) API"
description = "A detailed explanation of the peer to peer API."
date = 2024-01-01T00:00:00+00:00
updated = 2024-01-01T00:00:00+00:00
draft = false
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
This increases the jump value and searches a greater range for a common milestone.
It can only happen if we get a common milestone that isn't the same block as
our max height. If the target node is at block 100 and we're at block 89, the first search
with `lastBlockId` should count back by 10s, giving a common block of 80, but the second
search looks to count backwards by 20s. It will increase the jump distance in relation to
the distance between the two nodes' heights. This is likely to allow the node to quickly search
the entire blockchain for a common block.

If a `lastMilestoneBlockId` is requested that the target doesn't have, it appears to return
a the set of blocks identical to the initial query.

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

This endpoint returns the IDs of the next up to 100 blocks following the block for which
an ID is provided.

If 10 blocks exist, with IDs 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, then calling this action with
a `blockId` of '7' will return an array of 8, 9, and 10.

Request Fields:

* `blockId` the ID of any block in the chain.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 105

{
    "protocol": "B1",
    "requestType": "getNextBlockIds",
    "blockId": "17655301179078078080"
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
    "requestType": "getNextBlockIds",
    "blockId": "17655301179078078080"
}'
```

Response Fields:

* `nextBlockIds` an array of up to 100 block IDs immediately following the ID in the request.

Example Response:

```json
{
    "nextBlockIds": [
        "17509496500772329464",
        "9851554959281573956"
    ]
}
```

### getBlocksFromHeight

Returns a JSON object containing an array of entire blocks, ordered oldest to newest,
starting with the block immediately following the height requested with `height`, and
optionally limited to `numBlocks`.

Request Fields:

* `height` the height in the blockchain to begin.
* `numBlocks` optional limit on the number of blocks to return.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 111

{
    "protocol": "B1",
    "requestType": "getBlocksFromHeight",
    "height": 1962,
    "numBlocks": 2
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
    "requestType": "getBlocksFromHeight",
    "height": 1962,
    "numBlocks": 2
}'
```

Response Fields:

* `nextBlocks` an array of blocks beginning directly after the height requested.

Example Response:

```json
{
    "nextBlocks": [
        {
            "version": 3,
            "timestamp": 501340,
            "previousBlock": "4584982169599395303",
            "totalAmountNQT": 0,
            "totalFeeNQT": 0,
            "totalFeeCashBackNQT": 0,
            "totalFeeBurntNQT": 0,
            "payloadLength": 0,
            "payloadHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "generatorPublicKey": "f25d24f1ff10c69c23e75b54a9fe50c5ee2bfdd6c3418d09d84fe062b253e23c",
            "generationSignature": "ed1bc0818f115fab0cd249bc5c789c7a666b6f90742cc64423767952f9cee959",
            "previousBlockHash": "e7c578b0fd20a13f5b9385a710714386d1d57ff6dfd665a6197c8ca8167faac6",
            "blockSignature": "b412cfa25280a518080c702e84153478758a4b3640772dd8239aaf74c933e30ddd70ce6b1029e98802778987afad0065aa00f3dd776688a8a7eaf5f69127e2ae",
            "transactions": [],
            "nonce": "1166774",
            "baseTarget": "139287089",
            "blockATs": null
        },
        {
            "version": 3,
            "timestamp": 501730,
            "previousBlock": "9354106736727793056",
            "totalAmountNQT": 1000000000,
            "totalFeeNQT": 200000000,
            "totalFeeCashBackNQT": 0,
            "totalFeeBurntNQT": 0,
            "payloadLength": 334,
            "payloadHash": "4e48737232b06421ea2b38603f78975a875ca09ff9991d4ca0f5519c0818c0c7",
            "generatorPublicKey": "63cd1465f9dcee200deaeea57be83d1765704420fbd1d980ffde256717927d5a",
            "generationSignature": "f6e7cf9cf3cba538f926845c200180a52035f3f3612bf569d95d38f54b562beb",
            "previousBlockHash": "a09dbf518476d081c72a897f2d3836a6ed36837f6dbe2fe5f75f88daef90e2af",
            "blockSignature": "df5bbee02a813dbc06df695a525bd957220b4ca17e80066a8b81918defcc2f0aaf2916a3927626371be760d61d82bbe28251c7df4bf0d7129f7f1ab4d0d2342b",
            "transactions": [
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 501385,
                    "deadline": 1440,
                    "senderPublicKey": "0fcf782f9b032b1bbaf34fc68822909f8f3bb6e40fe625b5a50d5cf82eec071d",
                    "recipient": "16422175186807093330",
                    "amountNQT": 1000000000,
                    "feeNQT": 100000000,
                    "ecBlockHeight": 0,
                    "ecBlockId": "0",
                    "cashBackId": "0",
                    "signature": "4f88a148288c1cf6ba1e2f431f136d9e4e070be9b89d46e9e654db5a286ee1084752a78871dc4437bcbd29d266befa69cc297d2f0b52a685aa63364255fb67c8",
                    "attachment": {},
                    "version": 0
                },
                {
                    "type": 1,
                    "subtype": 0,
                    "timestamp": 501461,
                    "deadline": 1440,
                    "senderPublicKey": "b2c5645a7a7d137f8e25bf2c3a687ced8bdd2cbf28ded07234e58ed8af4ab341",
                    "recipient": "13096661501486641671",
                    "amountNQT": 0,
                    "feeNQT": 100000000,
                    "ecBlockHeight": 0,
                    "ecBlockId": "0",
                    "cashBackId": "0",
                    "signature": "ca8a63619d79306e261cf21112f5e8b75aa35b33edfa73bafca051dadfdcea0c827a53daf950fe7568c1565d948b30d6ba751c977e5bacab2081e0ef66e35eef",
                    "attachment": {
                        "message": "7468616e6b732062726f",
                        "messageIsText": false
                    },
                    "version": 0
                }
            ],
            "nonce": "157680",
            "baseTarget": "146357575",
            "blockATs": null
        }
    ]
}
```

### getNextBlocks

Returns a JSON object containing an array of blocks following a request `blockId`.
The number of blocks received from this request is either 1/2 of the Maximum Rollback value,
or a number set in the node's configuration.

Request Fields:

* `blockId` the ID of a block in the chain.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 103

{
    "protocol": "B1",
    "requestType": "getNextBlocks",
    "blockId": "12719136861414771996"
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
    "requestType": "getNextBlocks",
    "blockId": "12719136861414771996"
}'
```

Response Fields:

* `nextBlocks` an array of blocks beginning directly after the height requested.

Example Response:

```json
{
    "nextBlocks": [
        {
            "version": 4,
            "timestamp": 298332436,
            "previousBlock": "12719136861414771996",
            "totalAmountNQT": 3400000000,
            "totalFeeNQT": 108600000,
            "totalFeeCashBackNQT": 1250000,
            "totalFeeBurntNQT": 103600000,
            "payloadLength": 977,
            "payloadHash": "81e990d0d47783096a959459fe03d5dc1ed0b1725f9420e9049892c0d501c7b7",
            "generatorPublicKey": "2856ad42cf82d40beeb51383771952ea0d76b67c33b88ce69ccea5cdca1a5a32",
            "generationSignature": "ebd0ee5d74a45e6a63b82222818623a61e332bf5c1c87093bf04277416f097fb",
            "previousBlockHash": "1c4d342a967383b0257c1bcb8ab3ed73a4fb510a09fd16673dba17224b02b631",
            "blockSignature": "0665aa3eb6ba107eea5f85419809f9f07f0ae3bcd8030e1902719ada5072e60b3d480e8d09fc554f56b5d888cae4008da2ca65367d6cb003edab0a4e0125ea80",
            "transactions": [
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332398,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "df8e0e4316989534eaca8441c759be609652ad4e5e7ffc4139d998bae3375b0356dc187890107aebdd0c8a8bef0f9dc4c7cd7693221c524268aa08bf7cdf2c98",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332400,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "a722057e0a9e2bafbd2335e22415cf2cd569679a7165963e4dcea3dd230f720763b01101737b447bfcc4a63c1061c9481610106885f5c6c5c1facdf489a4c6bf",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 20,
                    "subtype": 1,
                    "timestamp": 298332277,
                    "deadline": 1440,
                    "senderPublicKey": "6ef637ea38abdaf5aab4c2944251ce89b10b9f4f1e88996fa348706d9f089e07",
                    "amountNQT": 0,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236838,
                    "ecBlockId": "9840412014607810403",
                    "cashBackId": "13420738867631717395",
                    "signature": "d8ed7fe3b96d1e6f61bf2775d2de3529451c869b80b184dc424d5c5e3a490f0fc0cbdb68214944152572d0cea65a6a67d1a7779e03314540660b50c0d2575001",
                    "attachment": {
                        "version.CommitmentAdd": 1,
                        "amountNQT": 1000000000
                    },
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332268,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236838,
                    "ecBlockId": "9840412014607810403",
                    "cashBackId": "13420738867631717395",
                    "signature": "54c3c682b0d6e7b54c90ff9b1d0d9c1e73feb9ab8d398f76390f98511c979b040c73fb2f95c2e0965fc6310035895d98d9ca639f9095897e726df1a49eb5cd1f",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332267,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236838,
                    "ecBlockId": "9840412014607810403",
                    "cashBackId": "13420738867631717395",
                    "signature": "66f72f975312213abb32069a95f8ec3aebc07b3069739f86d0d877c6b2465c0ff61f74860005a0ead725332ab9f8b22792de60666a41a14bc886a0c5925caf06",
                    "attachment": {},
                    "version": 2
                }
            ],
            "nonce": "17170354452813001494",
            "baseTarget": "6032946343509152816",
            "blockATs": "9949cc89a184bd46f83d3d4cc6d047efcdae2109a21a22b60319e3bdff90b38894e0ceeca74decadb3b6b7775c2f743e"
        },
        {
            "version": 4,
            "timestamp": 298332687,
            "previousBlock": "14533852665764262390",
            "totalAmountNQT": 13390000000,
            "totalFeeNQT": 106900000,
            "totalFeeCashBackNQT": 1000000,
            "totalFeeBurntNQT": 102900000,
            "payloadLength": 808,
            "payloadHash": "a4c1983e245981f3710f5131c7237f77b8a678ef9303e977bcb839888ac5743c",
            "generatorPublicKey": "59ddca1ec71a228b57de2eb7976bb6de8faec4c47ed9282b65192ed09055db35",
            "generationSignature": "03faf674bc18d95949f94f015a937c6e7317005edc86d19fa13d099ee5d4b1dc",
            "previousBlockHash": "f631bef0fe9db2c98b1770ee884ddd1c30f3ba3aa9628868a667e7787545c063",
            "blockSignature": "0fe836d9771642364bb0fd369a1e2a93d4b2554c4a9e4778fe59b1c98a6bb60af78997815c3b68b877fdab3444a6d46a36bfb7609c4943cb1d0c1437b89ee9ed",
            "transactions": [
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332661,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "e1bcff2121e8e0f3e9349cc01aa30f15fe555eef3511cac68b42d85006685e0cabf8c4a77102851b485828475559cfb825836302e56c52421becdf36a992d018",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332530,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "91d42399b2fb6522c38d321ef386ace46a2e38af77a36fadc982e5eb4370530590943616fb0e308a89794c5dfcfa2b61cafadc5b761f2c7ba8ad3ad6e9d358a3",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332531,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "7cc29eacce14bf231a5ed0cdc85fd6d297d2bd2a7794b71ce2631e56b67ea0065b667f4ae01e864599b47032823c3753397086bad6813dd2cacb1e0d61ac1787",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332660,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "629983e40d1545c489ee1b523e12197021284665d96675088bab7dce8cfc8e089791f1e598a88c6889ffa327caf7ddca8cc76ef9f2014577813b56f7e6be2580",
                    "attachment": {},
                    "version": 2
                }
            ],
            "nonce": "201612246958",
            "baseTarget": "6032678543708253984",
            "blockATs": "516f0885d7915f8c4660998cbc72aa32c04d5eadeb02685163f82fb370d341f433e8cac1145a0c831fdc89c0ee066ac10319e3bdff90b388b92f277dc4a344fa6f2599caa5d15922"
        }
    ]
}
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

Returns a JSON array with a list of of transaction objects the node is aware of but that have yet
to be confirmed by being forged into a block.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 76

{
    "protocol": "B1",
    "requestType": "getUnconfirmedTransactions"
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
    "requestType": "getUnconfirmedTransactions"
}'
```

Response Fields:

* `unconfirmedTransactions` an array of objects representing transactions.
Example Response:

```json
{
    "unconfirmedTransactions": [
        {
            "type": 2,
            "subtype": 1,
            "timestamp": 298326786,
            "deadline": 1440,
            "senderPublicKey": "789e1ecac7abc4ff7e776f2dedd2e9be6083d010efa0c6913f05507aa77b9340",
            "recipient": "17842702224298695831",
            "amountNQT": 0,
            "feeNQT": 2000000,
            "ecBlockHeight": 1236814,
            "ecBlockId": "11396976196756642613",
            "cashBackId": "17909721588112212347",
            "signature": "29f4548fb0a4a509a11c23fe9d8de49becc7d802dde4e56ce427be373b3d24038b0e5dff01438d8a42cb2db9cd76e99997394bb9ec0745911e72629c0bc24193",
            "attachment": {
                "version.AssetTransfer": 1,
                "asset": "14328689902698254062",
                "quantityQNT": 1000000
            },
            "version": 2
        }
    ]
}
```

### processBlock

Submits a single block to a node to be processed and recorded.

This request type is non-standard in that it doesn't use sub-properties of the root
object to define the block. The request root object is the JSON-serialized block itself,
with the protocol and requestType properties added directly to it.

Request Fields:

* `previousBlock` the ID of a block which submitted blocks must follow. Should be the top
of the blockchain. Used as an initial check to ensure valid blocks are being submitted.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: xx

{
    "protocol": "B1",
    "requestType": "processBlock",
    "version": 4,
    "timestamp": 298354767,
    "previousBlock": "18369301224889401486",
    "totalAmountNQT": 20995342056,
    "totalFeeNQT": 171800000,
    "totalFeeCashBackNQT": 1500000,
    "totalFeeBurntNQT": 165800000,
    "payloadLength": 1018,
    "payloadHash": "7fb2df2066af0e12ad2cccd2ae7ae673b3e8ee670ca37d39a34e894aaaf90349",
    "generatorPublicKey": "6a7b9f594ec0fbffd2bbe8109d5438be5e7747b9be456cba909773404aeb6278",
    "generationSignature": "ae339924f2cc8565d2a553d72b89d3f944d0fa76e042fc10e65852be769ca40c",
    "previousBlockHash": "8e40aea923deecfe0c2b1fb8dc31d4ef59197ed192b08a86cc5dbe8bd5c2554e",
    "blockSignature": "dacb615761b9a6619c97c9bf8777886eff55b7bce205f53f137d339168f7470fc3b3251a2f00c337636cf3d40617be03dd0c827b4b03ef0c2beeb568d748e6e7",
    "transactions": [
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354701,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "a1dd37dffdaec97d65f6b0d615ab06784f0727ca766f8875936eabb676ed30013b732380d0498992b3ea245362a56b7cae9d231bc77b6e66e8464e6a1eb55f93",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 1,
            "timestamp": 298354535,
            "deadline": 1440,
            "senderPublicKey": "3cd5610384aed89ace1550e54604b382394520089c14db4747fd1e8f188c5658",
            "amountNQT": 14595342056,
            "feeNQT": 2000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "14532404230105986816",
            "signature": "1b8d016bfb2828f1928c98e66f3b4be56f0ff05d73a29c5033df32aa69a3560e95733f15ae93c33940e3cb3f79359c3049137c2553b3a8b152660b1ab83a66ae",
            "attachment": {
                "version.MultiOutCreation": 1,
                "recipients": [
                    [
                        "17997500163001214854",
                        "2026541011"
                    ],
                    [
                        "12625359299301436821",
                        "9405744078"
                    ],
                    [
                        "12779054813723059063",
                        "3163056967"
                    ]
                ]
            },
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354571,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "73227bbeda56f251d13f02078ce913652a0235937498555268afdc2a9feff90d47c1caf1395eaac8a0f75947964670d26aa2e1226453a405c3536440f5a5447b",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354569,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "3fddd54dbf53441508fa2b7be9f347463bb4a2807f28abe14cf030d99f59360c6b7ed188cf641d38f0b69044a6747eba375a421de121c890cebb63c7d8e1d688",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354702,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "25dd574b1023f06b42b144caf77b8863d1f818f960622446c204ae9c0483ed0e78a14d12b9b063c3ea57da57e58107e005f87c996cb4c6d11f7cfe8ac368564e",
            "attachment": {},
            "version": 2
        }
    ],
    "nonce": "9983631486491223727",
    "baseTarget": "6036338955354410456",
    "blockATs": "c8b98c03e292de9ab3e1c6f4cdb803bab66cf8ad30b5274f0319e3bdff90b3881acce34052e5895c3e6b3b32e045f230"
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
    "requestType": "processBlock",
    "version": 4,
    "timestamp": 298354767,
    "previousBlock": "18369301224889401486",
    "totalAmountNQT": 20995342056,
    "totalFeeNQT": 171800000,
    "totalFeeCashBackNQT": 1500000,
    "totalFeeBurntNQT": 165800000,
    "payloadLength": 1018,
    "payloadHash": "7fb2df2066af0e12ad2cccd2ae7ae673b3e8ee670ca37d39a34e894aaaf90349",
    "generatorPublicKey": "6a7b9f594ec0fbffd2bbe8109d5438be5e7747b9be456cba909773404aeb6278",
    "generationSignature": "ae339924f2cc8565d2a553d72b89d3f944d0fa76e042fc10e65852be769ca40c",
    "previousBlockHash": "8e40aea923deecfe0c2b1fb8dc31d4ef59197ed192b08a86cc5dbe8bd5c2554e",
    "blockSignature": "dacb615761b9a6619c97c9bf8777886eff55b7bce205f53f137d339168f7470fc3b3251a2f00c337636cf3d40617be03dd0c827b4b03ef0c2beeb568d748e6e7",
    "transactions": [
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354701,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "a1dd37dffdaec97d65f6b0d615ab06784f0727ca766f8875936eabb676ed30013b732380d0498992b3ea245362a56b7cae9d231bc77b6e66e8464e6a1eb55f93",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 1,
            "timestamp": 298354535,
            "deadline": 1440,
            "senderPublicKey": "3cd5610384aed89ace1550e54604b382394520089c14db4747fd1e8f188c5658",
            "amountNQT": 14595342056,
            "feeNQT": 2000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "14532404230105986816",
            "signature": "1b8d016bfb2828f1928c98e66f3b4be56f0ff05d73a29c5033df32aa69a3560e95733f15ae93c33940e3cb3f79359c3049137c2553b3a8b152660b1ab83a66ae",
            "attachment": {
                "version.MultiOutCreation": 1,
                "recipients": [
                    [
                        "17997500163001214854",
                        "2026541011"
                    ],
                    [
                        "12625359299301436821",
                        "9405744078"
                    ],
                    [
                        "12779054813723059063",
                        "3163056967"
                    ]
                ]
            },
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354571,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "73227bbeda56f251d13f02078ce913652a0235937498555268afdc2a9feff90d47c1caf1395eaac8a0f75947964670d26aa2e1226453a405c3536440f5a5447b",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354569,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "3fddd54dbf53441508fa2b7be9f347463bb4a2807f28abe14cf030d99f59360c6b7ed188cf641d38f0b69044a6747eba375a421de121c890cebb63c7d8e1d688",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354702,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "25dd574b1023f06b42b144caf77b8863d1f818f960622446c204ae9c0483ed0e78a14d12b9b063c3ea57da57e58107e005f87c996cb4c6d11f7cfe8ac368564e",
            "attachment": {},
            "version": 2
        }
    ],
    "nonce": "9983631486491223727",
    "baseTarget": "6036338955354410456",
    "blockATs": "c8b98c03e292de9ab3e1c6f4cdb803bab66cf8ad30b5274f0319e3bdff90b3881acce34052e5895c3e6b3b32e045f230"
}'
```

Response Fields:

* `accepted` true or false depending on whether the blocks were valid to accept or not.

Example Response if Block is Rejected:

```json
{
    "accepted": false
}
```

Example Response if Block is Accepted:

```json
{
    "accepted": true
}
```

### processTransactions

Requests that the node process a list of one or more included transactions.

Request Fields:

* `transactions` a JSON array of JSON-serialized transaction objects.

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
=======
+++
title = "Peer to Peer (P2P) API"
description = "A detailed explanation of the peer to peer API."
date = 2024-01-01T00:00:00+00:00
updated = 2024-01-01T00:00:00+00:00
draft = false
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
This increases the jump value and searches a greater range for a common milestone.
It can only happen if we get a common milestone that isn't the same block as
our max height. If the target node is at block 100 and we're at block 89, the first search
with `lastBlockId` should count back by 10s, giving a common block of 80, but the second
search looks to count backwards by 20s. It will increase the jump distance in relation to
the distance between the two nodes' heights. This is likely to allow the node to quickly search
the entire blockchain for a common block.

If a `lastMilestoneBlockId` is requested that the target doesn't have, it appears to return
a the set of blocks identical to the initial query.

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

This endpoint returns the IDs of the next up to 100 blocks following the block for which
an ID is provided.

If 10 blocks exist, with IDs 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, then calling this action with
a `blockId` of '7' will return an array of 8, 9, and 10.

Request Fields:

* `blockId` the ID of any block in the chain.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 105

{
    "protocol": "B1",
    "requestType": "getNextBlockIds",
    "blockId": "17655301179078078080"
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
    "requestType": "getNextBlockIds",
    "blockId": "17655301179078078080"
}'
```

Response Fields:

* `nextBlockIds` an array of up to 100 block IDs immediately following the ID in the request.

Example Response:

```json
{
    "nextBlockIds": [
        "17509496500772329464",
        "9851554959281573956"
    ]
}
```

### getBlocksFromHeight

Returns a JSON object containing an array of entire blocks, ordered oldest to newest,
starting with the block immediately following the height requested with `height`, and
optionally limited to `numBlocks`.

Request Fields:

* `height` the height in the blockchain to begin.
* `numBlocks` optional limit on the number of blocks to return.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 111

{
    "protocol": "B1",
    "requestType": "getBlocksFromHeight",
    "height": 1962,
    "numBlocks": 2
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
    "requestType": "getBlocksFromHeight",
    "height": 1962,
    "numBlocks": 2
}'
```

Response Fields:

* `nextBlocks` an array of blocks beginning directly after the height requested.

Example Response:

```json
{
    "nextBlocks": [
        {
            "version": 3,
            "timestamp": 501340,
            "previousBlock": "4584982169599395303",
            "totalAmountNQT": 0,
            "totalFeeNQT": 0,
            "totalFeeCashBackNQT": 0,
            "totalFeeBurntNQT": 0,
            "payloadLength": 0,
            "payloadHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "generatorPublicKey": "f25d24f1ff10c69c23e75b54a9fe50c5ee2bfdd6c3418d09d84fe062b253e23c",
            "generationSignature": "ed1bc0818f115fab0cd249bc5c789c7a666b6f90742cc64423767952f9cee959",
            "previousBlockHash": "e7c578b0fd20a13f5b9385a710714386d1d57ff6dfd665a6197c8ca8167faac6",
            "blockSignature": "b412cfa25280a518080c702e84153478758a4b3640772dd8239aaf74c933e30ddd70ce6b1029e98802778987afad0065aa00f3dd776688a8a7eaf5f69127e2ae",
            "transactions": [],
            "nonce": "1166774",
            "baseTarget": "139287089",
            "blockATs": null
        },
        {
            "version": 3,
            "timestamp": 501730,
            "previousBlock": "9354106736727793056",
            "totalAmountNQT": 1000000000,
            "totalFeeNQT": 200000000,
            "totalFeeCashBackNQT": 0,
            "totalFeeBurntNQT": 0,
            "payloadLength": 334,
            "payloadHash": "4e48737232b06421ea2b38603f78975a875ca09ff9991d4ca0f5519c0818c0c7",
            "generatorPublicKey": "63cd1465f9dcee200deaeea57be83d1765704420fbd1d980ffde256717927d5a",
            "generationSignature": "f6e7cf9cf3cba538f926845c200180a52035f3f3612bf569d95d38f54b562beb",
            "previousBlockHash": "a09dbf518476d081c72a897f2d3836a6ed36837f6dbe2fe5f75f88daef90e2af",
            "blockSignature": "df5bbee02a813dbc06df695a525bd957220b4ca17e80066a8b81918defcc2f0aaf2916a3927626371be760d61d82bbe28251c7df4bf0d7129f7f1ab4d0d2342b",
            "transactions": [
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 501385,
                    "deadline": 1440,
                    "senderPublicKey": "0fcf782f9b032b1bbaf34fc68822909f8f3bb6e40fe625b5a50d5cf82eec071d",
                    "recipient": "16422175186807093330",
                    "amountNQT": 1000000000,
                    "feeNQT": 100000000,
                    "ecBlockHeight": 0,
                    "ecBlockId": "0",
                    "cashBackId": "0",
                    "signature": "4f88a148288c1cf6ba1e2f431f136d9e4e070be9b89d46e9e654db5a286ee1084752a78871dc4437bcbd29d266befa69cc297d2f0b52a685aa63364255fb67c8",
                    "attachment": {},
                    "version": 0
                },
                {
                    "type": 1,
                    "subtype": 0,
                    "timestamp": 501461,
                    "deadline": 1440,
                    "senderPublicKey": "b2c5645a7a7d137f8e25bf2c3a687ced8bdd2cbf28ded07234e58ed8af4ab341",
                    "recipient": "13096661501486641671",
                    "amountNQT": 0,
                    "feeNQT": 100000000,
                    "ecBlockHeight": 0,
                    "ecBlockId": "0",
                    "cashBackId": "0",
                    "signature": "ca8a63619d79306e261cf21112f5e8b75aa35b33edfa73bafca051dadfdcea0c827a53daf950fe7568c1565d948b30d6ba751c977e5bacab2081e0ef66e35eef",
                    "attachment": {
                        "message": "7468616e6b732062726f",
                        "messageIsText": false
                    },
                    "version": 0
                }
            ],
            "nonce": "157680",
            "baseTarget": "146357575",
            "blockATs": null
        }
    ]
}
```

### getNextBlocks

Returns a JSON object containing an array of blocks following a request `blockId`.
The number of blocks received from this request is either 1/2 of the Maximum Rollback value,
or a number set in the node's configuration.

Request Fields:

* `blockId` the ID of a block in the chain.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 103

{
    "protocol": "B1",
    "requestType": "getNextBlocks",
    "blockId": "12719136861414771996"
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
    "requestType": "getNextBlocks",
    "blockId": "12719136861414771996"
}'
```

Response Fields:

* `nextBlocks` an array of blocks beginning directly after the height requested.

Example Response:

```json
{
    "nextBlocks": [
        {
            "version": 4,
            "timestamp": 298332436,
            "previousBlock": "12719136861414771996",
            "totalAmountNQT": 3400000000,
            "totalFeeNQT": 108600000,
            "totalFeeCashBackNQT": 1250000,
            "totalFeeBurntNQT": 103600000,
            "payloadLength": 977,
            "payloadHash": "81e990d0d47783096a959459fe03d5dc1ed0b1725f9420e9049892c0d501c7b7",
            "generatorPublicKey": "2856ad42cf82d40beeb51383771952ea0d76b67c33b88ce69ccea5cdca1a5a32",
            "generationSignature": "ebd0ee5d74a45e6a63b82222818623a61e332bf5c1c87093bf04277416f097fb",
            "previousBlockHash": "1c4d342a967383b0257c1bcb8ab3ed73a4fb510a09fd16673dba17224b02b631",
            "blockSignature": "0665aa3eb6ba107eea5f85419809f9f07f0ae3bcd8030e1902719ada5072e60b3d480e8d09fc554f56b5d888cae4008da2ca65367d6cb003edab0a4e0125ea80",
            "transactions": [
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332398,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "df8e0e4316989534eaca8441c759be609652ad4e5e7ffc4139d998bae3375b0356dc187890107aebdd0c8a8bef0f9dc4c7cd7693221c524268aa08bf7cdf2c98",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332400,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "a722057e0a9e2bafbd2335e22415cf2cd569679a7165963e4dcea3dd230f720763b01101737b447bfcc4a63c1061c9481610106885f5c6c5c1facdf489a4c6bf",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 20,
                    "subtype": 1,
                    "timestamp": 298332277,
                    "deadline": 1440,
                    "senderPublicKey": "6ef637ea38abdaf5aab4c2944251ce89b10b9f4f1e88996fa348706d9f089e07",
                    "amountNQT": 0,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236838,
                    "ecBlockId": "9840412014607810403",
                    "cashBackId": "13420738867631717395",
                    "signature": "d8ed7fe3b96d1e6f61bf2775d2de3529451c869b80b184dc424d5c5e3a490f0fc0cbdb68214944152572d0cea65a6a67d1a7779e03314540660b50c0d2575001",
                    "attachment": {
                        "version.CommitmentAdd": 1,
                        "amountNQT": 1000000000
                    },
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332268,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236838,
                    "ecBlockId": "9840412014607810403",
                    "cashBackId": "13420738867631717395",
                    "signature": "54c3c682b0d6e7b54c90ff9b1d0d9c1e73feb9ab8d398f76390f98511c979b040c73fb2f95c2e0965fc6310035895d98d9ca639f9095897e726df1a49eb5cd1f",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332267,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236838,
                    "ecBlockId": "9840412014607810403",
                    "cashBackId": "13420738867631717395",
                    "signature": "66f72f975312213abb32069a95f8ec3aebc07b3069739f86d0d877c6b2465c0ff61f74860005a0ead725332ab9f8b22792de60666a41a14bc886a0c5925caf06",
                    "attachment": {},
                    "version": 2
                }
            ],
            "nonce": "17170354452813001494",
            "baseTarget": "6032946343509152816",
            "blockATs": "9949cc89a184bd46f83d3d4cc6d047efcdae2109a21a22b60319e3bdff90b38894e0ceeca74decadb3b6b7775c2f743e"
        },
        {
            "version": 4,
            "timestamp": 298332687,
            "previousBlock": "14533852665764262390",
            "totalAmountNQT": 13390000000,
            "totalFeeNQT": 106900000,
            "totalFeeCashBackNQT": 1000000,
            "totalFeeBurntNQT": 102900000,
            "payloadLength": 808,
            "payloadHash": "a4c1983e245981f3710f5131c7237f77b8a678ef9303e977bcb839888ac5743c",
            "generatorPublicKey": "59ddca1ec71a228b57de2eb7976bb6de8faec4c47ed9282b65192ed09055db35",
            "generationSignature": "03faf674bc18d95949f94f015a937c6e7317005edc86d19fa13d099ee5d4b1dc",
            "previousBlockHash": "f631bef0fe9db2c98b1770ee884ddd1c30f3ba3aa9628868a667e7787545c063",
            "blockSignature": "0fe836d9771642364bb0fd369a1e2a93d4b2554c4a9e4778fe59b1c98a6bb60af78997815c3b68b877fdab3444a6d46a36bfb7609c4943cb1d0c1437b89ee9ed",
            "transactions": [
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332661,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "e1bcff2121e8e0f3e9349cc01aa30f15fe555eef3511cac68b42d85006685e0cabf8c4a77102851b485828475559cfb825836302e56c52421becdf36a992d018",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332530,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "91d42399b2fb6522c38d321ef386ace46a2e38af77a36fadc982e5eb4370530590943616fb0e308a89794c5dfcfa2b61cafadc5b761f2c7ba8ad3ad6e9d358a3",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332531,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "13831709662995834087",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "7cc29eacce14bf231a5ed0cdc85fd6d297d2bd2a7794b71ce2631e56b67ea0065b667f4ae01e864599b47032823c3753397086bad6813dd2cacb1e0d61ac1787",
                    "attachment": {},
                    "version": 2
                },
                {
                    "type": 0,
                    "subtype": 0,
                    "timestamp": 298332660,
                    "deadline": 24,
                    "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
                    "recipient": "11130321392388236382",
                    "amountNQT": 500000000,
                    "feeNQT": 1000000,
                    "ecBlockHeight": 1236839,
                    "ecBlockId": "5664028750724787922",
                    "cashBackId": "13420738867631717395",
                    "signature": "629983e40d1545c489ee1b523e12197021284665d96675088bab7dce8cfc8e089791f1e598a88c6889ffa327caf7ddca8cc76ef9f2014577813b56f7e6be2580",
                    "attachment": {},
                    "version": 2
                }
            ],
            "nonce": "201612246958",
            "baseTarget": "6032678543708253984",
            "blockATs": "516f0885d7915f8c4660998cbc72aa32c04d5eadeb02685163f82fb370d341f433e8cac1145a0c831fdc89c0ee066ac10319e3bdff90b388b92f277dc4a344fa6f2599caa5d15922"
        }
    ]
}
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

Returns a JSON array with a list of of transaction objects the node is aware of but that have yet
to be confirmed by being forged into a block.

Example HTTP Request:

```http
POST / HTTP/1.1
Host: p2p.signumoasis.xyz:80
User-Agent: BRS/3.8.0
Connection: close
Content-Type: application/json
Content-Length: 76

{
    "protocol": "B1",
    "requestType": "getUnconfirmedTransactions"
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
    "requestType": "getUnconfirmedTransactions"
}'
```

Response Fields:

* `unconfirmedTransactions` an array of objects representing transactions.
Example Response:

```json
{
    "unconfirmedTransactions": [
        {
            "type": 2,
            "subtype": 1,
            "timestamp": 298326786,
            "deadline": 1440,
            "senderPublicKey": "789e1ecac7abc4ff7e776f2dedd2e9be6083d010efa0c6913f05507aa77b9340",
            "recipient": "17842702224298695831",
            "amountNQT": 0,
            "feeNQT": 2000000,
            "ecBlockHeight": 1236814,
            "ecBlockId": "11396976196756642613",
            "cashBackId": "17909721588112212347",
            "signature": "29f4548fb0a4a509a11c23fe9d8de49becc7d802dde4e56ce427be373b3d24038b0e5dff01438d8a42cb2db9cd76e99997394bb9ec0745911e72629c0bc24193",
            "attachment": {
                "version.AssetTransfer": 1,
                "asset": "14328689902698254062",
                "quantityQNT": 1000000
            },
            "version": 2
        }
    ]
}
```

### processBlock

Submits a single block to a node to be processed and recorded.

This request type is non-standard in that it doesn't use sub-properties of the root
object to define the block. The request root object is the JSON-serialized block itself,
with the protocol and requestType properties added directly to it.

Request Fields:

* `previousBlock` the ID of a block which submitted blocks must follow. Should be the top
of the blockchain. Used as an initial check to ensure valid blocks are being submitted.

Example HTTP Request:

```http
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "processBlock",
    "version": 4,
    "timestamp": 298354767,
    "previousBlock": "18369301224889401486",
    "totalAmountNQT": 20995342056,
    "totalFeeNQT": 171800000,
    "totalFeeCashBackNQT": 1500000,
    "totalFeeBurntNQT": 165800000,
    "payloadLength": 1018,
    "payloadHash": "7fb2df2066af0e12ad2cccd2ae7ae673b3e8ee670ca37d39a34e894aaaf90349",
    "generatorPublicKey": "6a7b9f594ec0fbffd2bbe8109d5438be5e7747b9be456cba909773404aeb6278",
    "generationSignature": "ae339924f2cc8565d2a553d72b89d3f944d0fa76e042fc10e65852be769ca40c",
    "previousBlockHash": "8e40aea923deecfe0c2b1fb8dc31d4ef59197ed192b08a86cc5dbe8bd5c2554e",
    "blockSignature": "dacb615761b9a6619c97c9bf8777886eff55b7bce205f53f137d339168f7470fc3b3251a2f00c337636cf3d40617be03dd0c827b4b03ef0c2beeb568d748e6e7",
    "transactions": [
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354701,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "a1dd37dffdaec97d65f6b0d615ab06784f0727ca766f8875936eabb676ed30013b732380d0498992b3ea245362a56b7cae9d231bc77b6e66e8464e6a1eb55f93",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 1,
            "timestamp": 298354535,
            "deadline": 1440,
            "senderPublicKey": "3cd5610384aed89ace1550e54604b382394520089c14db4747fd1e8f188c5658",
            "amountNQT": 14595342056,
            "feeNQT": 2000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "14532404230105986816",
            "signature": "1b8d016bfb2828f1928c98e66f3b4be56f0ff05d73a29c5033df32aa69a3560e95733f15ae93c33940e3cb3f79359c3049137c2553b3a8b152660b1ab83a66ae",
            "attachment": {
                "version.MultiOutCreation": 1,
                "recipients": [
                    [
                        "17997500163001214854",
                        "2026541011"
                    ],
                    [
                        "12625359299301436821",
                        "9405744078"
                    ],
                    [
                        "12779054813723059063",
                        "3163056967"
                    ]
                ]
            },
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354571,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "73227bbeda56f251d13f02078ce913652a0235937498555268afdc2a9feff90d47c1caf1395eaac8a0f75947964670d26aa2e1226453a405c3536440f5a5447b",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354569,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "3fddd54dbf53441508fa2b7be9f347463bb4a2807f28abe14cf030d99f59360c6b7ed188cf641d38f0b69044a6747eba375a421de121c890cebb63c7d8e1d688",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354702,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "25dd574b1023f06b42b144caf77b8863d1f818f960622446c204ae9c0483ed0e78a14d12b9b063c3ea57da57e58107e005f87c996cb4c6d11f7cfe8ac368564e",
            "attachment": {},
            "version": 2
        }
    ],
    "nonce": "9983631486491223727",
    "baseTarget": "6036338955354410456",
    "blockATs": "c8b98c03e292de9ab3e1c6f4cdb803bab66cf8ad30b5274f0319e3bdff90b3881acce34052e5895c3e6b3b32e045f230"
}'
```

Example curl Request:

```bash
curl --location 'http://p2p.signumoasis.xyz:80' \
--header 'User-Agent: BRS/3.8.0' \
--header 'Connection: close' \
--header 'Content-Type: application/json' \
--data '{
    "protocol": "B1",
    "requestType": "processBlock",
    "version": 4,
    "timestamp": 298354767,
    "previousBlock": "18369301224889401486",
    "totalAmountNQT": 20995342056,
    "totalFeeNQT": 171800000,
    "totalFeeCashBackNQT": 1500000,
    "totalFeeBurntNQT": 165800000,
    "payloadLength": 1018,
    "payloadHash": "7fb2df2066af0e12ad2cccd2ae7ae673b3e8ee670ca37d39a34e894aaaf90349",
    "generatorPublicKey": "6a7b9f594ec0fbffd2bbe8109d5438be5e7747b9be456cba909773404aeb6278",
    "generationSignature": "ae339924f2cc8565d2a553d72b89d3f944d0fa76e042fc10e65852be769ca40c",
    "previousBlockHash": "8e40aea923deecfe0c2b1fb8dc31d4ef59197ed192b08a86cc5dbe8bd5c2554e",
    "blockSignature": "dacb615761b9a6619c97c9bf8777886eff55b7bce205f53f137d339168f7470fc3b3251a2f00c337636cf3d40617be03dd0c827b4b03ef0c2beeb568d748e6e7",
    "transactions": [
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354701,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "a1dd37dffdaec97d65f6b0d615ab06784f0727ca766f8875936eabb676ed30013b732380d0498992b3ea245362a56b7cae9d231bc77b6e66e8464e6a1eb55f93",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 1,
            "timestamp": 298354535,
            "deadline": 1440,
            "senderPublicKey": "3cd5610384aed89ace1550e54604b382394520089c14db4747fd1e8f188c5658",
            "amountNQT": 14595342056,
            "feeNQT": 2000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "14532404230105986816",
            "signature": "1b8d016bfb2828f1928c98e66f3b4be56f0ff05d73a29c5033df32aa69a3560e95733f15ae93c33940e3cb3f79359c3049137c2553b3a8b152660b1ab83a66ae",
            "attachment": {
                "version.MultiOutCreation": 1,
                "recipients": [
                    [
                        "17997500163001214854",
                        "2026541011"
                    ],
                    [
                        "12625359299301436821",
                        "9405744078"
                    ],
                    [
                        "12779054813723059063",
                        "3163056967"
                    ]
                ]
            },
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354571,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "73227bbeda56f251d13f02078ce913652a0235937498555268afdc2a9feff90d47c1caf1395eaac8a0f75947964670d26aa2e1226453a405c3536440f5a5447b",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354569,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "11130321392388236382",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236932,
            "ecBlockId": "15206958044651677745",
            "cashBackId": "13420738867631717395",
            "signature": "3fddd54dbf53441508fa2b7be9f347463bb4a2807f28abe14cf030d99f59360c6b7ed188cf641d38f0b69044a6747eba375a421de121c890cebb63c7d8e1d688",
            "attachment": {},
            "version": 2
        },
        {
            "type": 0,
            "subtype": 0,
            "timestamp": 298354702,
            "deadline": 24,
            "senderPublicKey": "0936031e61748b9a724dc95ee9fc5292e4f5282ac3d1cf3c8d40b4d822e7213c",
            "recipient": "13831709662995834087",
            "amountNQT": 500000000,
            "feeNQT": 1000000,
            "ecBlockHeight": 1236933,
            "ecBlockId": "15722498062156268369",
            "cashBackId": "13420738867631717395",
            "signature": "25dd574b1023f06b42b144caf77b8863d1f818f960622446c204ae9c0483ed0e78a14d12b9b063c3ea57da57e58107e005f87c996cb4c6d11f7cfe8ac368564e",
            "attachment": {},
            "version": 2
        }
    ],
    "nonce": "9983631486491223727",
    "baseTarget": "6036338955354410456",
    "blockATs": "c8b98c03e292de9ab3e1c6f4cdb803bab66cf8ad30b5274f0319e3bdff90b3881acce34052e5895c3e6b3b32e045f230"
}'
```

Response Fields:

* `accepted` true or false depending on whether the blocks were valid to accept or not.

Example Response if Block is Rejected:

```json
{
    "accepted": false
}
```

Example Response if Block is Accepted:

```json
{
    "accepted": true
}
```

### processTransactions

Requests that the node process a list of one or more included transactions.

Request Fields:

* `transactions` a JSON array of JSON-serialized transaction objects.

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
