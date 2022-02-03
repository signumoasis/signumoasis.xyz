+++
title = "Block"
description = "A description of a single Block."
date = 2022-02-01T00:00:00+00:00
updated = 2022-02-01T00:00:00+00:00
draft = false
weight = 10
sort_by = "weight"
template = "docs/page.html"

[extra]
# lead = "A description of a single Block."
toc = true
top = false
+++

## Structure in Memory

* **Block Version Number**
    * What block version this block is. As the protocol and data evolve with newer versions of the software, this will increment.
    * Versions in the database: 1, 2, 3
    * Current version: 3
* **List of Transaction IDs**
    * A list of all the transactions' IDs that are included in this block.
* **Payload Hash**
    * A SHA-256 hash of all the data in this block's payload field.
* **Timestamp**
    * The time this block was forged, based on the start of the blockchain at 11 August 2014, Time: 02:00:00.
    * _TODO: Add the format of this timestamp_
* **Total amount of Signa**
    * The sum of the coins sent in transactions in this block.
* **Total amount of Fees charged**
    * The sum of the fees charged for messages, transactions, and smart contracts running in this block.
    * This amount goes to the account that forged this block.
* **Length of Payload**
    * The total number of bytes of the entire payload field.
* **Forger Public Key**
    * The public key of the account that forged this block.
* **Generation Signature**
    * The 32-byte generation signature used to forge this block.
* **Previous Block Hash**
    * The SHA-256 hash of the contents of the previous block.
* **Previous Block ID**
    * The first 8 bytes of the previous block hash converted into a number.
    * _TODO: Add the datatype of the number_
* **Cumulative Difficulty**
    * This is used to prevent nothing-at-stake problems during potential forks.
    * Calculated with `PreviousCumulativeDifficulty + (18446744073709551616 / base target)`
* **Base Target**
    * Base target to be used when forging this block
    * TODO: Reword this definition to remove the recursion
* **Height**
    * The height of this block in the chain.
* **Block ID**
    * The first 8 bytes of this block's contents converted into a number.
    * _TODO: Add the datatype of the number_
* **Nonce**
    * The nonce number used to forge this block.
    * _TODO: Define this better_
* **AT Bytes**
    * The bytes of an AT that may be present in this block
    * Optional
    * _TODO: Rename this field maybe and reword its description_
* **Block Signature**
    * A 64-bit hash generated from the forger's private key and the block contents.


## Structure in BRS Database
