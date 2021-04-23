# Binary Prediction Market

## Overview
This is a monolithic lazily loaded smart contract implementation of binary prediction markets, based on Uniswap-like liquidity pools, with an auction / seeding phase to raise liquidity before enabling swaps.

## Market lifecycle

### - Creation:
Anyone may create a new market and set its metadata. Each market is denominated in a currency that the market's creator can specify, by supplying a contract address adhering to the FA1.2 or FA2 token standard. All purchases and rewards happen in this token. The risk of zombie markets denominated in non-existent or defunct tokens is reduced by the requirement of the market creator to place an initial bet in the token specified.

The market creator also has to specify an adjudicator address. This address alone is allowed to make a call to resolve the market (ie. claim that the event has happened, and the question resolved to either Yes or No.) For testing purposes, this can be an intrinsic account, but ideally in real life, it should be a glue contract interpreting on-chain data supplied by an oracle.

The permissionless nature of market creation does not allow for a DOS attack vector, and indexers have the ability to filter markets by any criteria.

### - Auction:
To raise liquidity in the market, the market creator can specify an auction period, where liquidity providers can place bets specifying their expected probability of a Yes outcome.

Bets cannot be withdrawn, but can be augmented. Any subsequent bets made by a participant will be merged into their former bets in a weighted manner.

### - Clearing:
After the expiry of the specified auction period, anyone can make a call to clear the market. 

Auction participants are allocated Yes and No outcome tokens according to the clearing probability prediction, and their preferences. The liquidity pool is automatically seeded from auction participants' token allocations according to the maths specified in the whitepaper.

The full amount of Yes and No tokens, as well as liquidity tokens, are minted into the liquidity pool, and into reserves (for auction participants to withdraw their allocations at will.)

After this point, auction bets are no longer accepted, and trading through the liquidity pool starts.

### - Trading:
During the trading phase, the market behaves as a combination of a mint/burn mechanic, and a traditional liquidity pool.

Market participants can pay the market's specified currency to mint Yes / No token pairs (each unit of currency can be split into one Yes and one No token unit), exit the market by burning Yes / No token pairs to retrieve currency, swap these outcome tokens for each other, and add or remove liquidity from the pool.

Both entering the market and swapping outcome tokens is subject to a fee. These collected fees are allocated by the contract to reward auction participants and liquidity providers.

### - Resolution:
The adjudicator can at any time call the function to resolve the market, once the outcome of the predicted event can be unequivocally determined. This is to ensure that markets for a non-strictly time-bound event can be resolved in a timely manner.

Eg. "Will the weekly Coronavirus incidence per 100.000 in Berlin sink below 35 before midnight 2021 June 1?" This market would have to be resolved as a "Yes" as soon as weekly incidence number drops below 35, or as a "No" on midnight June 1, if the numbers have yet to sink below this number.

Such logic is far too complex and varied to be considered the responsibility of the market itself, and should be handled in a separate adjudicator contract.

If the market is resolved during the auction phase, the auction is immediately cleared, regardless of specified auction time remaining.

### - Claims
Once the market had been cleared, participants can claim their winnings in the market's currency token. These winnings are calculated from the sum total of their holdings in the winning outcome token, pool liquidity token, and liquidity provider reward tokens.

## Liquidity provider incentives
Two fee structures are in place to reward and incentivize liquidity providers, and encourage them to provide liquidity until the market resolution.

### Swap fee - liquidity pool reward
Following the behavior of Uniswap v1 liquidity pools, a small fee is taken from each swap operation, raising the effective K of the pool. This fee is denominated in the outcome token being sold. This leads to the liquidity tokens appreciating over time in comparison to the outcome tokens, with continued trading in the pool.

This approach has a major flaw in the domain of prediction markets. As the market nears resolution, the holdings of the eventual winning token will likely decrease in the pool compared to the losing token, the liquidity providers' so-called impermanent loss becoming a permanent loss, unless the market is resolved to the more unlikely outcome. This creates a potential disincentive for continuing to provide liquidity.

### Mint fee - time-proportional and seeding reward
To create an incentive for market participants to take part in the auction phase and seed the pool, and to continue to provide liquidity up till the resolution of the market, additional reward mechanics have been implemented. A fee is taken from the minting and burning of outcome tokens. This fee is denominated in the market currency token, and is effected by a spread between the mint and burn prices of outcome tokens. The currency collected through this mint / burn fee is split into two reward pools in a 20% / 80% ratio.

20% goes to rewarding auction participants according to the relative size of their bets, to counterbalance the risk of taking part in a nascent, unseeded market and helping it to come into existence.

80% of the fees go to rewarding liquidity providers for continuing to hold tokens in the liquidity pool. Each block, every liquidity provider is allocated newly minted liquidity reward tokens relative to the liquidity they are providing. (Naturally, these rewards are calculated in a lazy manner, whenever a participant executes a liquidity operation.) These reward tokens start to accrue as the market is cleared, and continue accruing until the market is finally resolved.

