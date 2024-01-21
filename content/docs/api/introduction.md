+++
title = "Introduction"
description = "A quick introduction to the APIs that run Signum."
date = 2024-01-01T00:00:00+00:00
updated = 2024-01-01T00:00:00+00:00
draft = true
weight = 10
sort_by = "weight"
template = "docs/page.html"

[extra]
# lead = "A description of the API"
toc = true
top = false
+++

Signum has two separate APIs. One exists for the wallet apps to communicate
with, and the other is for the nodes to talk with each other. This documentation
refers to them as the Wallet or Web API, and the Peer to Peer or P2P API.

## Wallet / Web API

The Wallet API is designed for wallet software and only has Denial of Service (DoS)
protections enabled. Other than an attack, it is safe to make requests to any number
of times, and unlike the P2P API, it will not blacklist your client. The primary
purpose of this API is to allow the management of individual Signum accounts,
sending and receiving transactions, and other user tasks.

[Read about the Wallet API →](../wallet.md)

## Peer to Peer (P2P) API

The Peer to Peer API is primarily designed for nodes to talk with each other,
though it can be used to get certain information that may not be readily available via
the wallet API. This should be done sparingly, however, as the node software is designed
to automatically black list IP addresses making incorrect requests, or spamming
the API.

[Read about the Peer to Peer API →](../p2p.md)
