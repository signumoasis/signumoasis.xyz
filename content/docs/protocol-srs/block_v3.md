+++
title = "Block (Version 3)"
description = "A description of a single version 3 block."
date = 2022-02-01T00:00:00+00:00
updated = 2024-05-22T00:00:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
toc = true
top = false
+++
<mark>ATTENTION: This page is out of date and waiting to be updated. It may be inaccurate.</mark>

A field-by-field description of Signum's v3 block.

_NOTE: Signum started with block version 3 when forked from NXT. It does not have anything older._

## B1 P2P JSON Model

The fields are listed here in the order they are seen from the BRS software's p2p API.
However, JSON does not require them in this order, so long as they are present.

* **Version**
  * Description: The version of this block. Should be `3` for block version 3.
  * Key: `version`
  * Type: `number`
* **Time Stamp**
  * Description: The time this block was forged, represented in seconds since the genesis block
  was forged at *2014-08-11T02:00:00+0000*.
  * Key: `timestamp`
  * Type: `number`
* **Previous Block ID**
  * Description: The first 8 bytes of the previous block hash converted into a number.
  * Key: `previousBlock`
  * Type: `string` (`Unsigned 64 bit integer` as `String`)
* **Total Amount of Signa in NQT**
  * Description: The total amount of Signa transferred in this block, measured in NQT.
  * Key: `totalAmountNQT`
  * Type: `number`
* **Total Fee in NQT**
  * Description: The total amount of fees paid in this block, measured in NQT.
  * Key: `totalFeeNQT`
  * Type: `number`
* **Payload Length**
  * Description: The total number of bytes of this block's entire payload field.
  * Key: `payloadLength`
  * Type: `number`
* **Payload Hash**
  * Description: The SHA-256 hash of all of the data in this block's payload field.
  * Key: `payloadHash`
  * Type: `string` (Hex encoded bytes)
* **Generator Public Key**
  * Description: The public key of the account that forged this block.
  * Key: `generatorPublicKey`
  * Type: `string` (Hex encoded bytes)
* **Generation Signature**
  * Description: The 32-byte generation signature used to forge this block.
  * Key: `generationSignature`
  * Type: `string` (Hex encoded bytes)
* **Previous Block Hash**
  * Description: The SHA-256 hash of the previous block. Used to ensure the blocks are
  cryptographically linked in correct order. <br>*(NOTE: Only if block version > 1, which should
  always be the case for Signum.)*
  * Key: `previousBlockHash`
  * Type: `string` (Hex encoded bytes)
* **Block Signature**
  * Description: A hash generated from the forger's private key and the block's contents.
  * Key: `blockSignature`
  * Type: `string` (Hex encoded bytes)
* **Transactions**
  * Description: An array of JSON-formatted objects. (See [Transaction](/docs/protocol-srs/transaction))
  * Key: `transactions`
  * Type: `array of object`
* **Nonce**
  * Description: The nonce number used to forge this block.
  * Key: `nonce`
  * Type: `string` (`Unsigned 64 bit integer` as `String`)
* **Base Target**
  * Description: A value set by the node used in forging the block, adjusted each block to try and
  keep an average 4-minute per block time.
  * Key: `baseTarget`
  * Type: `string` (`Unsigned 64 bit integer` as `String`)
* **Block ATs**
  * Description: The bytes of an AT that may be present in this block.
  * Key: `blockATs`
  * Type: `string` (Hex encoded bytes)

## Representation of Bytes When Verifying

Here is the list of fields that should exist on a block in memory to properly create the hash
and forge the block.

Notes about the structure:

* The byte order must be Little Endian.
* The bytes must be directly concatenated in a single large buffer.
* The length of the buffer will change depending on the block version and if any ATs are added.
* There is additional information related to blocks that does not get included in this calculation,
but are necessary to store for operational quickness.

1. **Block Version Number**
    * Datatype: `Signed 32 bit integer`
    * What block version this block is. As the protocol and data evolve with newer versions of the software, this will increment.
    * Current version: `3`
2. **Timestamp**
    * Datatype: `Signed 32 bit integer`
    * The time this block was forged, based on the start of the blockchain at 11 August 2014, Time: 02:00:00.
    * _TODO: Add the format of this timestamp_
3. **Previous Block ID**
    * Datatype: `Signed 64 bit integer`
    * The first 8 bytes of the previous block hash converted into a number.
    * _TODO: Add the datatype of the number_
4. **Total amount of Signa**
    * Block version < 3
        * Datatype: `Signed 32 bit integer`
        * Value: total amount of NQT / 100000000
    * Block version >= 3
        * Datatype: `Signed 64 bit integer`
        * Value: total amount of NQT
    * The sum of the coins sent in transactions in this block.
5. **Total amount of Fees charged**
    * Block version < 3
        * Datatype: `Signed 32 bit integer`
        * Value: total amount of NQT / 100000000
    * Block version >= 3
        * Datatype: `Signed 64 bit integer`
        * Value: total amount of NQT
    * The sum of the fees charged for messages, transactions, and smart contracts running in this block.
    * This amount goes to the account that forged this block.
6. **Length of Payload**
    * Datatype: `Signed 32 bit integer`
    * The total number of bytes of the entire payload field.
7. **Payload Hash**
    * Datatype: `32 raw bytes`
    * A SHA-256 hash of all the data in this block's payload field.
8. **Forger Public Key**
    * Datatype: `32 raw bytes`
    * The public key of the account that forged this block.
9. **Generation Signature**
    * Datatype: `32 raw bytes`
    * The 32-byte generation signature used to forge this block.
10. **Previous Block Hash**
    * Block version > 1
    * Datatype: `32 raw bytes`
    * The SHA-256 hash of the contents of the previous block.
11. **Nonce**
    * Datatype: `Signed 64 bit integer`
    * The nonce number used to forge this block.
    * _TODO: Define this better_
12. **AT Bytes**
    * Datatype: `Raw bytes, length of AT`
    * The bytes of an AT that may be present in this block
    * Optional
    * _TODO: Rename this field maybe and reword its description_
13. **Block Signature**
    * Datatype: `64 raw bytes`
    * A hash generated from the forger's private key and the block contents.

