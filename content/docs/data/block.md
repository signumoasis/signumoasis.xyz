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

## Json Model

The block is represented in json when transmitted over the API. The fields are listed here in the order
they are seen in the BRS software. However, json does not require them in this order, so long as they are present.

* **Version**
    * Key: `version`
    * Value Datatype: `number`
* **Timestamp**
    * Key: `timestamp`
    * Value Datatype: `number`
* **Previous Block ID**
    * Key: `previousBlock`
    * Value Datatype: `string` (`Unsigned 64 bit integer` as `String`)
* **Total Amount of Signa in NQT**
    * Key: `totalAmountNQT`
    * Value Datatype: `number`
* **Total Fee in NQT**
    * Key: `totalFeeNQT`
    * Value Datatype: `number`
* **Payload Length**
    * Key: `payloadLength`
    * Value Datatype: `number`
* **Payload Hash**
    * Key: `payloadHash`
    * Value Datatype: `string` (Hex encoded bytes)
* **Generator Public Key**
    * Key: `generatorPublicKey`
    * Value Datatype: `string` (Hex encoded bytes)
* **Generation Signature**
    * Key: `generationSignature`
    * Value Datatype: `string` (Hex encoded bytes)
* **Previous Block Hash**
    * Only if block version > 1
    * Key: `previousBlockHash`
    * Value Datatype: `string` (Hex encoded bytes)
* **Block Signature**
    * Key: `blockSignature`
    * Value Datatype: `string` (Hex encoded bytes)
* **Transactions**
    * Key: `transactions`
    * Value Datatype: `array of object` (See [Transaction](/docs/data/transaction))
* **Nonce**
    * Key: `nonce`
    * Value Datatype: `string` (`Unsigned 64 bit integer` as `String`)
* **Base Target**
    * Key: `baseTarget`
    * Value Datatype: `string` (`Unsigned 64 bit integer` as `String`)
* **Block ATs**
    * Key: `blockATs`
    * Value Datatype: `string` (Hex encoded bytes)


## Structure of Bytes to Forge the Block

Here is the list of fields that should exist on a block in memory to properly create the hash and forge the block.

Notes about the structure:
* The byte order must be Little Endian.
* The bytes must be directly concatenated in a single large buffer.
* The length of the buffer will change depending on the block version and if any ATs are added.
* There are additional fields related to blocks that do not get included in this, but are necessary to store.
    See the database structures.

1. **Block Version Number**
    * Datatype: `Signed 32 bit integer`
    * What block version this block is. As the protocol and data evolve with newer versions of the software, this will increment.
    * Versions in the database: 1, 2, 3
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










## Database Structure - BRS

_as of v3.3.2_

**NOTE: THIS SECTION IS INCOMPLETE**

This is a list of the fields seen in the node database along with their database built-in datatypes.
This is unlikely to change with versions of the node unless a new block version is debuted.

<!-- * **List of Transaction IDs**
    * A list of all the transactions' IDs that are included in this block.
* **Cumulative Difficulty**
    * This is used to prevent nothing-at-stake problems during potential forks.
    * Calculated with `PreviousCumulativeDifficulty + (18446744073709551616 / base target)`
* **Base Target**
    * Base target to be used when forging this block
    * _TODO: Reword this definition to remove the recursion_
* **Height**
    * The height of this block in the chain.
* **Block ID**
    * The first 8 bytes of this block's contents converted into a number.
    * _TODO: Add the datatype of the number_ -->

* **Database ID**
    * Field name: `db_id`
    * Data type: `BIGINT`

* **Block ID**
    * Field name: `id`
    * Data type: `BIGINT`

* **Version**
    * Field name: `version`
    * Data type: `INTEGER`

* **Timestamp**
    * Field name: `timestamp`
    * Data type: `INTEGER`

* **Previous Block ID**
    * Field name: `previous_block_id`
    * Data type: `INTEGER`

* **Total Amount**
    * Field name: `total_amount`
    * Data type: `BIGINT`

* **Total Fee**
    * Field name: `total_fee`
    * Data type: `BIGINT`

* **Payload Length**
    * Field name: `payload_length`
    * Data type: `INTEGER`

* **Generator Public Key**
    * Field name: `generator_public_key`
    * Data type: `VARBINARY`

* **Previous Block Hash**
    * Field name: `previous_block_hash`
    * Data type: `VARBINARY`

* **Cumulative Difficulty**
    * Field name: `cumulative_difficulty`
    * Data type: `VARBINARY`

* **Base Target**
    * Field name: `base_target`
    * Data type: `BIGINT`

* **Next Block ID**
    * Field name: `next_block_id`
    * Data type: `BIGINT`

* **Height**
    * Field name: `height`
    * Data type: `INTEGER`

* **Generation Signature**
    * Field name: `generation_signature`
    * Data type: `VARBINARY`

* **Block Signature**
    * Field name: `block_signature`
    * Data type: `VARBINARY`

* **Payload Hash**
    * Field name: `payload_hash`
    * Data type: `VARBINARY`

* **Generator ID**
    * Field name: `generator_id`
    * Data type: `BIGINT`

* **Nonce**
    * Field name: `none`
    * Data type: `BIGINT`

* **Block ATs**
    * Field name: `ats`
    * Data type: `VARBINARY`