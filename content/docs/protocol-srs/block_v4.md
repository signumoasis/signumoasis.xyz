+++
title = "Block (Version 4)"
description = "A description of a single version 3 block."
date = 2024-05-22T00:00:00+00:00
updated = 2024-05-22T00:00:00+00:00
draft = false
weight = 19
sort_by = "weight"
template = "docs/page.html"

[extra]
toc = true
top = false
+++

A field-by-field description of Signum's v4 block.

_NOTE: Signum started with block version 3 when forked from NXT. The only older block is the
genesis block, which has a version of `-1`._

## B1 P2P JSON Model

The fields are listed here in the order they are seen from the BRS software's p2p API.
However, JSON does not require them in this order, so long as they are present.

### Version
The version of this block. Should be `4` for block version 4.

  * Key: `version`
  * Type: `number`

### Time Stamp
The time this block was forged, represented in seconds since the genesis block
was forged at _2014-08-11T02:00:00+0000_.

  * Key: `timestamp`
  * Type: `number`

### Previous Block ID
The first 8 bytes of the previous block hash converted into a number.

  * Key: `previousBlock`
  * Type: `string` (`Unsigned 64 bit integer` as `String`)

### Total Amount of Signa in NQT
The total amount of Signa transferred in this block, measured in NQT.

  * Key: `totalAmountNQT`
  * Type: `number`

### Total Fee in NQT
The total amount of fees paid in this block, measured in NQT.

  * Key: `totalFeeNQT`
  * Type: `number`

### Total Fee Towards Cash Back NQT
The total amount of Signa sent to cash back in this block, measured in NQT.

  * Key: `totalFeeCashBackNQT`
  * Type: `number`

### Total Fee Burnt in NQT
The total amount of Signa burnt in this block, measured in NQT.

  * Key: `totalFeeBurntNQT`
  * Type: `number`

### Payload Length
The total number of bytes of this block's entire payload field.

  * Key: `payloadLength`
  * Type: `number`

### Payload Hash
The SHA-256 hash of all of the data in this block's payload field.

  * Key: `payloadHash`
  * Type: `string` (Hex encoded bytes)

### Generator Public Key
The public key of the account that forged this block.

  * Key: `generatorPublicKey`
  * Type: `string` (Hex encoded bytes)

### Generation Signature
The 32-byte generation signature used to forge this block.

  * Key: `generationSignature`
  * Type: `string` (Hex encoded bytes)

### Previous Block Hash
The SHA-256 hash of the previous block. Used to ensure the blocks are
cryptographically linked in correct order. <br>*(NOTE: Only if block version > 1, which should
always be the case for Signum.)*

  * Key: `previousBlockHash`
  * Type: `string` (Hex encoded bytes)

### Block Signature
A hash generated from the forger's private key and the block's contents.

  * Key: `blockSignature`
  * Type: `string` (Hex encoded bytes)

### Transactions
An array of JSON-formatted objects. (See [Transaction](/docs/protocol-srs/transaction))

  * Key: `transactions`
  * Type: `array of object`

### Nonce
The nonce number used to forge this block.

  * Key: `nonce`
  * Type: `string` (`Unsigned 64 bit integer` as `String`)

### Base Target
A value set by the node used in forging the block, adjusted each block to try and
keep an average 4-minute per block time.

  * Key: `baseTarget`
  * Type: `string` (`Unsigned 64 bit integer` as `String`)

### Block ATs
The bytes of an AT that may be present in this block.

  * Key: `blockATs`
  * Type: `string` (Hex encoded bytes)

## Representation of Bytes When Verifying

Here is the list of fields that should exist on a block in memory to properly create the hash
and forge the block. The table is a short quick-reference and more details about each field are
available in the list below it.

Notes about the structure:

* The byte order must be Little Endian.
* The bytes must be concatenated in a single large buffer without padding, field markers, or names.
* The length of the buffer will change depending on the block version and if any ATs are added.
* There is additional information related to blocks that does not get included in this calculation,
but are necessary to store for operational quickness.

_NOTE: These are not the actual names of database fields, but just identifiers to use when talking
about these. There are no field names in the bytes representation._

|  # | Data                            | Type                    | Size         |
|---:|---------------------------------|-------------------------|--------------|
|  1 | Version Number                  | `Signed 32-bit integer` | 4 bytes      |
|  2 | Time Stamp                      | `Signed 32-bit integer` | 4 bytes      |
|  3 | Previous Block ID               | `Signed 64-bit integer` | 8 bytes      |
|  4 | Number of Transactions          | `Signed 32-bit integer` | 4 bytes      |
| *5 | Total Amount of Signa (< v3)    | `Signed 32-bit integer` | 4 bytes      |
| *5 | Total Amount of Signa (>= v3)   | `Signed 64-bit integer` | 8 bytes      |
| *6 | Total Amount of Fees (< v3)     | `Signed 32-bit integer` | 4 bytes      |
| *6 | Total Amount of Fees (>= v3)    | `Signed 64-bit integer` | 8 bytes      |
|  7 | Length of Payload               | `Signed 32-bit integer` | 4 bytes      |
|  8 | Payload Hash                    | `Raw bytes`          | 32 bytes     |
|  9 | Generator Public Key            | `Raw bytes`          | 32 bytes     |
| 10 | Generation Signature            | `Raw bytes`          | 32 bytes     |
| 11 | Previous Block Hash             | `Raw bytes`          | 32 bytes     |
| 12 | Nonce                           | `Signed 64-bit integer` | 8 bytes      |
| 13 | AT Bytes                        | `Raw bytes`             | Length of AT |

_* These fields will only appear once. They must be sized differently depending on the version
of the block. The only block in Signum this might affect is the Genesis block, but it must still
be taken into account._

1. **Version Number**
  * Description: What block version this block is. As the protocol and data evolve with newer
  versions of the software, this will increment.
  * Type: `Signed 32-bit integer`
  * Length: 4 bytes
  * Current version: `3`
2. **Timestamp**
  * Description: The time this block was forged, represented in seconds since the genesis block
  was forged at _2014-08-11T02:00:00+0000_.
  * Type: `Signed 32-bit integer`
  * Length: 4 bytes
3. **Previous Block ID**
  * Description: The first 8 bytes of the previous block hash converted into a number.
  * Length: 8 bytes
  * Type: `Signed 64-bit integer`
4. **Number of Transactions**
  * Description: The total number of transactions included in this block.
  * Type: `Signed 32-bit integer`
  * Length: 4 bytes
5. **Total amount of Signa**
  * Description: The sum of the coins sent in transactions in this block.
  * Block version < 3
    * NOTE: Not relevant to Signum - holdover from NXT
    * Type: `Signed 32-bit integer`
    * Length: 4 bytes
    * Value: total amount of NQT / 100000000
  * Block version >= 3
    * Type: `Signed 64-bit integer`
    * Length: 8 bytes
    * Value: total amount of NQT
6. **Total amount of Fees charged**
  * Description: The sum of the fees charged for messages, transactions, and smart contracts
  running in this block. This amount goes to the account that forged this block.
  * Block version < 3
    * Type: `Signed 32-bit integer`
    * Length: 4 bytes
    * Value: total amount of NQT / 100000000
  * Block version >= 3
    * Type: `Signed 64-bit integer`
    * Length: 8 bytes
    * Value: total amount of NQT
7. **Length of Payload**
  * Description: The total number of bytes of the entire payload field.
  * Type: `Signed 32-bit integer`
  * Length: 4 bytes
8. **Payload Hash**
  * Description: A SHA-256 hash of all the data in this block's payload field.
  * Type: `32 raw bytes`
  * Length: 32 bytes
9. **Generator Public Key**
  * Description: The public key of the account that forged this block.
  * Type: `32 raw bytes`
  * Length: 32 bytes
10. **Generation Signature**
  * Description: The 32-byte generation signature used to forge this block.
  * Type: `32 raw bytes`
  * Length: 32 bytes
11. **Previous Block Hash**
  * Description: The SHA-256 hash of the contents of the previous block.
  * Block version > 1 (ALWAYS for Signum)
  * Type: `32 raw bytes`
  * Length: 32 bytes
12. **Nonce**
  * Description: The nonce (one-time use number) used to forge this block.
  * Type: `Signed 64-bit integer`
  * Length: 8 bytes
13. **AT Bytes**
  * Description: The bytes of an AT that may be present in this block
  * Type: `Raw bytes, length of AT`
  * Length: (total length of ATs, or 0 if no ATs)
  * Optional
<!-- NOTE: The block signature (final 64 bits) is stripped from getBytes() for signing. Consider removing here -->
<!--14. **Block Signature**-->
<!--  * Description: A hash generated from the forger's private key and the block contents.-->
<!--  * Type: `64 raw bytes`-->
<!--  * Length: 64 bytes-->


### Additional Fields Needed in Database

<mark>_NOTE: THIS SECTION IS INCOMPLETE AND MAY BE INACCURATE._</mark>

This is a list of additional fields that are not included in the block hashing process
but which should be stored in the database. It is likely most, if not all of this, can be
derived from the data required to create the block, but this is not guaranteed.

* **Database ID**
  * Description: The ID of the block in the database. Can be the Block ID or height if desired.
  Just a way to uniquely identify the database record.
  * Field name: `db_id`
  * Type: `BIGINT`

* **Block ID**
  * Description: The block ID. A hash of the block's signed bytes where the first 8 bytes are
  converted to a 64-bit integer to be used as the ID.
  * Field name: `id`
  * Type: `BIGINT`

* **Cumulative Difficulty**
  * Field name: `cumulative_difficulty`
  * Type: `VARBINARY`

* **Base Target**
  * Field name: `base_target`
  * Type: `BIGINT`

* **Next Block ID**
  * Field name: `next_block_id`
  * Type: `BIGINT`

* **Height**
  * Field name: `height`
  * Type: `INTEGER`

* **Generator ID**
  * Field name: `generator_id`
  * Type: `BIGINT`

* **Total Fees for Cash Back**
  * Description: Non-authoritative. A convenience field to speed up data retrieval. Value
  calculated from total fees * a percentage. ( _NOTE: This is speculation._ )
  * Field name: `total_fee_cash_back`
  * Type: `INTEGER`
* **Total Fees Burnt**
  * Description: Non-authoritative. A convenience field to speed up data retrieval. Value
  calculated from transactions sent to known "burn" accounts.
  * Field name: `total_fee_burnt`
  * Type: `INTEGER`

## Block Signature

### Inputs
* Message
  * Description: The bytes to sign
  * Type: `byte[]` -- array of bytes
* Private Key
  * Description: The bytes of the private key used to sign the message
  * Type: `byte[]` -- array of bytes

### Algorithm
1. Get a SHA-256 hash of the message bytes.
2. Sign the hash with the private key using the EC25519 algorithm.
3. Use the signed bytes or store them.

## Related Algorithms

### Bytes to Long LE
The SRS java implementation of the conversion from a SHA-256 of the block's bytes (with signature)
into a 64-bit integer using little endian during the conversion, resulting in the block ID.
```java
public long bytesToLongLE(byte[] bytes, int offset) {
    return ((long) (bytes[offset] & 0xFF))
            | (((long) (bytes[offset + 1] & 0xFF)) << 8)
            | (((long) (bytes[offset + 2] & 0xFF)) << 16)
            | (((long) (bytes[offset + 3] & 0xFF)) << 24)
            | (((long) (bytes[offset + 4] & 0xFF)) << 32)
            | (((long) (bytes[offset + 5] & 0xFF)) << 40)
            | (((long) (bytes[offset + 6] & 0xFF)) << 48)
            | (((long) (bytes[offset + 7] & 0xFF)) << 56);
}
```
