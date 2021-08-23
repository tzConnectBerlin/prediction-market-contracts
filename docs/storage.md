# Storage and internal behavior
This document describes the structure and semantics of the contract storage, as described in LIGO.

## Storage shape

* `lambda_repository` : The storage of the lazy loading mechanism, holding the lazily loaded code parts, and metadata. Plays no semantic role in the operation of the prediction markets.
* `business_storage` : The actual storage root of the prediction market logic.
  * `tokens` : Storage root for built-in FA2 token functionality; note that FA2 functionality is at the moment incomplete
    * `ledger_map : Big_map` : Map of ledger entries
	  * Key
	    * `owner : address`
		* `token_id : nat`
	  * Value (`nat`) : Ledger balance
	* `supply_map : Big_map` : Map of token supply entries
	  * Key (`nat`) : Token identifier
	  * `total_supply : nat` : Total supply minted of the token (including reserve)
	  * `in_reserve : nat` : Pool of minted but unclaimed tokens
  * `markets` : Storage root for prediction market data
    * `create_restrictions` : Restrictions on market creation, to be set at contract deployment
	  * `creator_address : address option` : The sole address allowed to create new markets (optional)
	  * `currency : external_token option` : The sole token to be allowed as market currency (optional)
	    * *(For type internals, see below in currency metadata.)*
    * `market_map : Big_map` : Map of all prediction markets
	  * Key (`nat`) : A user-specified arbitrary-size identifier
	  * `metadata` : Descriptive information about the market
		* `ipfs_hash : string option` : An optional hash for relevant metadata of the market stored in ipfs
	    * `description : string` : A human-readable description of the market question
		* `adjudicator : address` : The address authorized to resolve the market
		* `currency : external_token` : Union type describing the token used as the market currency, of the following options:
		  * `FA12 : address` : The address of an FA1.2 token contract
		  * `FA2`
		    * `token_address : address`
			* `token_id : nat`
	  * `state` : Market state vector (does not include liquidity pool balances, as those are held as FA2 ledger entries.) Union type of the following options:
	    * `AuctionRunning` : The auction is still in progress
		  * `auction_period_end : timestamp` : The time after which the auction can be cleared at will
		  * `quantity : nat` : Total amount of currency tokens collected through bets
		  * `yes_preference : fixedpoint` : Internal bookkeeping
		  * `uniswap_contribution : fixedpoint` : Internal bookkeeping
		* `MarketBootstrapped` : The auction had been cleared, and the market is trading or had been resolved
		  * `currency_pool` : Running totals of collected currency
		    * `market_currency_pool : nat` : Currency reserved for burning outcome tokens or exchange for winning tokens after market resolution
			* `liquidity_reward_currency_pool : nat` : Currency reserved for rewarding liquidity providers proportional to keeping liquidity in the pool
			* `creator_reward_currency_pool : nat` : Currency reserved for rewarding the market creator
		  * `bootstrap_yes_probability : fixedpoint` : Predicted probability of Yes outcome at the point of market clearing. Used for calculating auction withdrawals
		  * `bootstrapped_at_block : nat` : Block level at which the market had been cleared and trading began
		  * `liquidity_reward_supply_updated_at_block : nat` : Block level at which the liquidity reward token supply had last been updated
		  * `resolution : option` : If `Some`, indicates that the market had been resolved
		    * `winning_prediction : outcome_type` : Yes or No
			* `resolved_at_block : nat` : Block level at which the market had been resolved
	* `liquidity_provider_map : Big_map` : Map of auction participants and liquidity providers.
	  * Key
	    * `originator : address` : Address of the liquidity provider
		* `market_id : nat` : The prediction market for which liquidity is provided
	  * Union type of the following options
	    * `Liquidity_reward_updated_at : nat` : Block level where this liquidity provider has had their reward tokens withdrawn
		* `Bet` : If the liquidity provider had participated in the auction, and not withdrawn their allocations yet, this type holds the details of their bet
		  * `predicted_probability : fixedpoint` : A fixed point representation of the probability of a Yes outcome predicted in the bet
		  * `quantity : nat` : The amount of currency tokens placed down for the bet

## Details

### Fixed point numbers
Fractional numbers and those requiring high precision are handled in a base2 fixed point representation.

Fixed point numbers are represented by the `fixedpoint` type that doesn't unify with `nat` in LIGO, but compiles to a simple `nat` in Michelson. This is to make interoperability simple, while ensuring correct semantics at compile time.

The conversion from `nat` to `fixedpoint` is a left-shift by 64 bits, while conversion back (essentially implementing a floor function) is a right-shift by the same.

Fixed point 1.0 is represented as 2^64.

### Token-market mapping
Tokens and markets are mapped to each other in a deterministic fashion. The basis of a market's token identifiers is gained by left-shifting the market id by 3.

* Outcome tokens:
  * No token : `%{market_id}000`
  * Yes token : `%{market_id}001`
* Other tokens:
  * Pool liquidity token: `%{market_id}010`
  * Auction reward token: `%{market_id}011`
  * Liquidity reward token: `%{market_id}100`

### Liquidity pool state

The liquidity pool is defined by the contract's (`self_address`) own holdings of the FA2 outcome tokens belonging to the market. Pool liquidity is given by the liquidity token's total supply.
