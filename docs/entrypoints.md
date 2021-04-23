# Entrypoints and use
This document describes the business entrypoints and their arguments. All argument lists are represented in Michelson as location retaining right combed trees.

## FA2 token operations
FA2 entrypoints are at the time unimplemented, making the internal tokens untransferrable. Internal structure is in place to implement a standard FA2 token interface.

## Market operations


## `%marketCreate`
Create a new prediction market

### Call restrictions
* `market_id` has to be unique

### Arguments
* `market_id : nat` : An arbitrary identifier for the new market
* `metadata`
  * `ipfs_hash : string option` : An optional hash for relevant metadata of the market stored in ipfs
  * `description : string` : A human-readable description of the market question
  * `adjudicator : address` : The address authorized to resolve the market
  * `currency` : Union type describing the token used as the market currency, of the following options:
    * `FA12 : address` : The address of an FA1.2 token contract
    * `FA2`
      * `token_address : address`
	  * `token_id : nat`
* `auction_period_end : timestamp` : 
* `bet` : Details of the creator's initial bet
  * `predicted_probability : fixedpoint` : A fixed point representation of the probability of a Yes outcome predicted in the bet
  * `quantity : nat` : The amount of currency tokens placed down for the bet

## `%auctionBet`
Place a new bet in the auction (or augmenting an existing one)

### Call restrictions
* The market has to exist
* The market must not have been cleared

### Arguments
* `market_id : nat`
* `bet`
  * `predicted_probability : fixedpoint` : A fixed point representation of the probability of a Yes outcome predicted in the bet
  * `quantity : nat` : The amount of currency tokens placed down for the bet

## %auctionClear
Clear a market after the auction phase

### Call restrictions
* The market has to exist
* The market must not have been cleared
* `auction_period_end` has to be in the past

### Arguments
* `market_id : nat`

## %auctionWithdraw
Withdraw allocated tokens from a bet in the auction

### Call restrictions
* The market has to exist
* The market must have been cleared

### Arguments
* `market_id : nat`

## %marketEnterExit
Enter or exit the market by minting or burning outcome token pairs in exchange for market currency tokens

### Call restrictions
* The market has to exist
* The market must have been cleared
* The market must not have been resolved

### Arguments
* `direction` : Union type of the following options
  * `PayIn` : Enter the market by paying currency tokens
  * `PayOut` : Exit the market and receive currency tokens
* `params`
  * `market_id : nat`
  * `amount : nat` : The amount of outcome token pairs to mint or burn

## %swapTokens
Swap one outcome token through the liquidity pool for its opposing pair as a fixed input swap operation

### Call restrictions
* The market has to exist
* The market must have been cleared
* The market must not have been resolved

### Arguments
* `token_to_sell` : Union type of the following options
  * `Yes`
  * `No`
* `params`
  * `market_id : nat`
  * `amount : nat` : The amount of token to sell

## %swapLiquidity
Add or remove liquidity from the liquidity pool at the current ratio

### Call restrictions
* The market has to exist
* The market must have been cleared
* The market must not have been resolved

### Arguments
* `direction` : Union type of the following options
  * `PayIn` : Add liquidity to the pool
  * `PayOut` : Remove liquidity from the pool
* `params`
  * `market_id : nat`
  * `amount : nat` : The amount of liquidity tokens to receive or burn

## %marketResolve
Resolve the market to a known outcome

### Call restrictions
* The market has to exist
* The caller must be the market's `adjudicator`
* The market must not have been resolved

### Arguments
* `market_id : nat`
* `winning_prediction` : Union type of the following options
  * `Yes`
  * `No`

## %claimWinnings
Claim winnings in market currency tokens from a resolved market. The sum received is a composite payout from burning tokens of the following types held by the caller:
* Winning outcome token
* Pool liquidity token (converted to winning outcome token through a remove liquidity operation)
* Liquidity provider time reward token
* Auction participant reward token

### Call restrictions
* The market has to exist
* The market must have been resolved

### Arguments
* `market_id : nat`
