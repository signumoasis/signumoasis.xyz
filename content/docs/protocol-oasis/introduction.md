+++
title = "Introduction"
description = "A quick introduction to the Signum Oasis APIs and data."
date = 2024-01-01T00:00:00+00:00
updated = 2024-01-01T00:00:00+00:00
draft = false
weight = 10
sort_by = "weight"
template = "docs/page.html"

[extra]
# lead = "A description of the API"
toc = true
top = false
+++
Signum Oasis is an implementation of the Signum Reference Software (SRS) in rust.
The SRS is the original node first forked from a currency
called NXT. It has two separate APIs. One exists for the wallet apps to communicate
with, and the other is for the nodes to talk with each other. This documentation
refers to them as the SRS Wallet or SRS Web API, and the SRS Peer to Peer or SRS P2P API.

## SRS Wallet / SRS Web API

The SRS Wallet API is designed for wallet software and only has Denial of Service (DoS)
protections enabled. Other than an attack, it is safe to make requests to any number
of times, and unlike the SRS P2P API, it will not blacklist your client. The primary
purpose of this API is to allow the management of individual Signum accounts,
sending and receiving transactions, and other user tasks.

<!-- [Read about the Wallet API →](../srs-wallet) -->

## SRS Peer to Peer (P2P) API

The SRS Peer to Peer API is primarily designed for nodes to talk with each other,
though it can be used to get certain information that may not be readily available via
the wallet API. This should be done sparingly, however, as the node software is designed
to automatically black list IP addresses making incorrect requests, or spamming
the API.

[Read about the SRS Peer to Peer API →](../srs-p2p)
