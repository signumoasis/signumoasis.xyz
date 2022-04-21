+++
title = "Transaction"
description = "A description of a single transaction."
date = 2022-02-01T00:00:00+00:00
updated = 2022-02-01T00:00:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
# lead = "A description of a single transaction."
toc = true
top = false
+++

## JSON Model

NOTE: This is the base json model in the BRS Transaction class. The API contains additional fields that will be discussed on the API page.

* **Type**
    * Key: `type`
    * Value Datatype: `number` (`byte` encoded as a number)
* **Sub Type**
    * Key: `subtype`
    * Value Datatype: `number` (`byte` encoded as a number)
* **Timestamp**
    * Key: `timestamp`
    * Value Datatype: `number`
* **Deadline**
    * Key: `deadline`
    * Value Datatype: `number`
* **Sender Public Key**
    * Key: `senderPublicKey`
    * Value Datatype: `string` (Hex encoded bytes)
* **Recipient**
    * Key: `recipient`
    * Value Datatype: `string` (`Unsigned 64 bit integer` as `String`)
* **Amount in NQT**
    * Key: `amountNQT`
    * Value Datatype: `number`
* **Fees Amount in NQT**
    * Key: `feeNQT`
    * Value Datatype: `number`
* **Referenced Transaction Full Hash**
    * Key: `referencedTransactionFullHash`
    * Value Datatype: `string`
    * _TODO: Figure out if this should be byte array maybe_
* **ecBlockHeight**
    * Key: `ecBlockHeight`
    * Value Datatype: `number`
* **ecBlockId**
    * Key: `ecBlockId`
    * Value Datatype: `string` (`Unsigned 64 bit integer` as `String`)
* **Signature**
    * Key: `signature`
    * Value Datatype: `string` (Hex encoded bytes)
* **Attachment**
    * Key: `attachment`
    * Value Datatype: `array of object` (JSON object array)
* **Version**
    * Key: `version`
    * Value Datatype: `number`

## Structure of Bytes Representation

1. **Transaction Type**
    * Datatype: `Byte`
    * The type of transaction. [(See Transaction Types and Subtypes section)](#transaction-types-and-subtypes)

1. **Transaction Subtype**
    * Datatype: `byte`
    * The subtype of the transaction. [(See Transaction Types and Subtypes section)](#transaction-types-and-subtypes)

1. **Timestamp**
    * Datatype: `Signed 32 bit integer`
    * The time of the transaction in _<UNIT>_ since the beginning of the chain.
    * _TODO: LIST TIMEZONE, PROBABLY UTC_

1. **Deadline**
    * Datatype: `Signed 16 bit integer`
    * The deadline to forge a block including this transaction. It will be lost if this passes.

1. **Signature**
    * Datatype: `32 raw bytes`
    * 
    * This depends on the block's height and when a certain update was released at block 255000.
        * If it is signed, append the public key of the sender.
        * If not signed but _before_ AT_FIX_BLOCK_4 upgrade, append the sender's public key.
        * If not signed but _after_ the AT_FIX_BLOCK_4 upgrade, append a `Signed 64 bit integer` that is the sender's account ID, followed by 24 empty bytes (all zeros).
    * _TODO: Define AT_FIX_BLOCK_4 better_

1. **Recipient**
    * Datatype: `Signed 64 bit integer`
    * Depends on whether the transaction has a specified single recipient.
        * If a recipient exists, include the recipient's ID.
        * If no recipient exists, include the 'Zero' account. The value should just be `0`.

1. **Amount of Signa being Sent in this Transaction**
    * This field depends on the height of the block for both datatype and value.
    * Block height >= Constants.NQT_BLOCK (`0` for Signum)
        * Datatype: `Signed 64 bit integer`
        * Amount in NQT.
    * Block height < Constants.NQT_BLOCK
        * Datatype: `Signed 32 bit integer` 
        * Amount in NQT divided by One Signa in NQT (100,000,000).
    * _TODO: Remove the conditional if [https://github.com/signum-network/signum-node/pull/596](https://github.com/signum-network/signum-node/pull/596) is merged_

1. **Amount of Fees for this Transaction**
    * This field depends on the height of the block for both datatype and value.
    * Block height >= Constants.NQT_BLOCK (`0` for Signum)
        * Datatype: `Signed 64 bit integer`
        * Amount in NQT.
    * Block height < Constants.NQT_BLOCK
        * Datatype: `Signed 32 bit integer` 
        * Amount in NQT divided by One Signa in NQT (100,000,000).
    * _TODO: Remove the conditional if [https://github.com/signum-network/signum-node/pull/596](https://github.com/signum-network/signum-node/pull/596) is merged_

1. **Referenced Transaction Full Hash**
    * This field depends on the height of the block for both datatype and value.
    * Block height >= Constants.NQT_BLOCK (`0` for signum)
        * Datatype: `32 raw bytes`
        * The full hash bytes of the referenced transaction, or 32 empty bytes if no transaction is referenced.
    * Block height < Constants.NQT_BLOCK
        * Datatype: `Signed 64 bit integer` 
        * The referenced transaction ID or `0` if there is no referenced transaction.
    * _TODO: Remove the conditional if [https://github.com/signum-network/signum-node/pull/596](https://github.com/signum-network/signum-node/pull/596) is merged_

1. **Transaction Signature**
    * Datatype: `64 raw bytes`
    * The signature for this transaction.

1. **Transaction Flags**
    * Optional: Include only if transaction version is greater than zero.
    * Datatype: `Signed 32 bit integer`
    * A set of bit flags encoded into a single integer via a bitwise OR:
        * `00000001` = _`message`_ flag 
        * `00000010` = _`encryptedMessage`_ flag
        * `00000100` = _`publicKeyAnnouncement`_ flag
        * `00001000` = _`encryptToSelfMessage`_ flag

1. **Transaction ec Block Height**
    * Optional: Include only if transaction version is greater than zero.
    * Datatype: `Signed 32 bit integer`
    * _TODO: Figure out what `ecBlockHeight` is_

1. **Transaction ec Block ID**
    * Optional: Include only if transaction version is greater than zero.
    * Datatype: `Signed 64 bit integer`
    * _TODO: Figure out what `ecBlockId` is_

1. **Appendages**
    * Datatype: `Raw bytes`
    * ???

## Database Fields in BRS

## Transaction Types and Subtypes

* **Payment**
    * Value: `0`
    * Subtypes:
        * Ordinary Payment
            * Value: `0`
        * Ordinary Payment Multi-out
            * Value: `1`
        * Ordinary Payment Same-out
            * Value: `2`
* **Messaging**
    * Value: `1`
    * Subtypes:
        * _Arbitray Message_
            * Value: `0`
        * _Alias Assignment_
            * Value: `1`
        * _Account Info_
            * Value: `5`
        * _Alias Sell_
            * Value: `6`
        * _Alias Buy_
            * Value: `7`
* **Colored Coins**
    * Value: `2`
    * Subtypes:
        * _Asset Issuance_
            * Value: `0`
        * _Asset Transfer_
            * Value: `1`
        * _Ask Order Placement_
            * Value: `2`
        * _Bid Order Placement_
            * Value: `3`
        * _Ask Order Cancellation_
            * Value: `4`
        * _Bid Order Cancellation_
            * Value: `5`
        * _Asset Mint_
            * Value: `6`
        * _Add Treasury Account_
            * Value: `7`
        * _Distribute to Holders_
            * Value: `8`
* **Digital Goods**
    * Value: `3`
    * Subtypes:
        * _Listing_
            * Value: `0`
        * _Delisting_
            * Value: `1`
        * _Price Change_
            * Value: `2`
        * _Quantity Change_
            * Value: `3`
        * _Purchase_
            * Value: `4`
        * _Delivery_
            * Value: `5`
        * _Feedback_
            * Value: `6`
        * _Refund_
            * Value: `7`
* **Account Control**
    * Value: `4`
    * Subtypes:
        * _Effective Balance Leasing_
            * Value: `0`
* **Mining**
    * Value: `20`
    * Subtypes:
        * _Reward Recipient Assignment_
            * Value: `0`
        * _Commitment Add_
            * Value: `1`
        * _Commitment Remove_
            * Value: `2`
* **Advanced Payment**
    * Value: `21`
    * Subtypes:
        * _Escrow Creation_
            * Value: `0`
        * _Escrow Sign_
            * Value: `1`
        * _Escrow Result_
            * Value: `2`
        * _Subscription Subscribe_
            * Value: `3`
        * _Subscription Cancel_
            * Value: `4`
        * _Subscription Payment_
            * Value: `5`
* **Automated Transaction**
    * Value: `22`
    * Subtypes:
        * _Creation_
            * Value: `0`
        * _NXT Payment_
            * Value: `1`
