+++
title = "Hello Signum Oasis"
date = 2024-01-15
updated = 2024-01-15
draft = false
template = "blog/page.html"

[taxonomies]
authors = ["damccull"]

[extra]
lead = "Introducing Signum Oasis, a rust implementation of Signum."
+++

Signum Oasis aims to be a full-rust implementation of the Signum crypto currency node and wallet.
It is in very early development and the idea is to use this blog to document the development of it.
The corresponding Docs pages will document the technical information while this blog is intended
to show the how and why, rather than the what.

# Goals
I plan for Signum Oasis to be a self-contained code base that holds both the wallet and the node
server, and can conditionally compile to create a full, combined software or two separate parts.
Users should be able to run any combination of:
* a node and wallet as a single desktop app (or mobile app!)
* a mobile wallet GUI that connects to a remote node
* a headless node server without any included UI

I plan to use the Dioxus framework to give the app this ability unless something better comes along.

# Basic Design
As of now, the plan is to separate the app into several parts internally, not including the GUI.
* A Blockchain or Chain service, responsible for all reads and writes to the data store, as well
as verification and caching of incoming blocks.
* A Protocol service per protocol that will be responsible to:
  * serialize, deserialize, transmit, and receive blocks from peers
  * seek out peers and maintain a collection of them
  * communicate with the Chain service to record or retrieve blocks
  * register all endpoints the protocol needs with a centralized web service
  * handle all API endpoints relevant to the particular protocol
* A Web service that will host a web ui, if enabled on the server, any protocol API endpoints,
and any Signum Oasis generic endpoints

For the datastore, the current plan is to use SurrealDB as an embedded library, allowing connections
to both a local file or a SurrealDB server. Constraining the choice of datastore to a single database
option will make overall development easier and prevent confusion about which choice to use.
SurrealDB also offers the ability to look up a block by ID or height without a table scan, making
block retrieval very quick and cheap to perform. It also works with data in a json-like structure,
making conversion to json itself a breeze.

I intend to implement two protocols: SRS's B1 protocol, which is the default Signum p2p protocol;
and Oasis Protocol, a custom protocol I'm building over gRPC. The plan is for the Oasis protocol
to be faster to discover peers and sync blocks during large syncs through concurrent processing
rather than processing a single block at a time like B1.


I'm sure the new node will take a long time to complete, and I'm working on it in my free time.
Indeed, like many projects, it may never see release, but it is a fun project that I enjoy working
on and I will do my best to get it out. I'm not currently planning to take any help on the node itself
but I will welcome pull requests to the SRS Protocol documentation under the Docs tab.
