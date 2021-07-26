# Krisa* : A Decentralized Prediction Market Platform

( * - Working name; *Krisa* was the original name of the site of the Delphoi shrine to Apollo according to the Homeric hymns. )

*Krisa* is an automated system developed as an open source smart contract for the Tezos blockchain, that allows users to create and participate in binary prediction markets.

## Binary prediction market

Prediction markets are exchange-traded markets created for the purpose of trading the outcome of events. The market prices can indicate what the crowd thinks the probability of the event is. A binary prediction market can resolve according two $2$ different outcomes, designated as $yes$ and $no$ answers pertaining to a prediction. Once the answer becomes known, the market is resolved to one of these two outcomes, at which point the correct prediction expires at a price of $100\%$, and the incorrect at $0\%$. ([Wikipedia](https://en.wikipedia.org/wiki/Prediction_market))

In Krisa, the open trading phase of the market is realized using a liquidity pool based on the $x * y = k$ mathematics pioneered by Uniswap v1. This is a decentralized exchange technology, where a single liquidity pool serves as automated market maker, providing exchange of two assets for one another at spot prices based on the built-in mathematics. The fundamental concept is as follows:

$$x_0 * y_0 = x_1 * y_1 = k$$

Where $x_0$ and $y_0$ are the original asset amounts in the pool, while $x_1$ and $y_1$ those after the exchange. In reality, a fee is collected on each swap, which means $k$ will in effect slowly grow over time, which provides incentive for keeping liquidity in the pool, for a share of its ownership. An exchange of $\Delta x$ of one asset for $\Delta y$ of the other would thus be described by the following equation, assuming a fee of $0 \leq \rho \lt 1$:

$$x_0 * y_0 = (x_0 + (1-\rho)\Delta x) * (y_0 - \Delta y) $$

The swap fee implemented in *Krisa* is in line with the Uniswap fee at $0.3\%$ or $\rho = 0.003$. ([Zhang et al., 2018](https://github.com/runtimeverification/verified-smart-contracts/blob/uniswap/uniswap/x-y-k.pdf))

The liquidity pool in a *Krisa* market allows for the exchange of $yes$ and $no$ tokens for one another, and thus to adjust one's position according to preferences. Entry and exit from the market does not happen through a liquidity pool, but via a fixed price mint / burn mechanic:

### Entering and exiting the market

In *Krisa*, the $yes$ and $no$ outcome contracts are represented as FA2 fungible tokens connected to the market in question. In an open market, entering and exiting the market is realized by respectively minting and burning outcome token pairs. Each pair of outcome tokens is nominally equivalent to $1$ currency token specified at market creation, in which the market is denominated. By locking up $1$ currency token in the market, one has the ability to mint a pair consisting of a $yes$ and $no$ tokens. In reality, outcome tokens are discounted by a redemption fee, which serves to incentivize market creators to drive traffic to the market, as well as an serving as an additional reward to liquidity providers, to offset the distortions expected at the tail end of a market lifecycle. Thus, the discounted value of an outcome token pair is $(1 - \sigma)$, where $\sigma$ is a different and separate fee from the above mentioned uniswap fee, set in *Krisa* as $5\%$ or $\sigma = 0.05$. In an open market, $Q * (1 - \sigma)$ currency tokens may be unlocked by burning $Q$ pairs of outcome tokens.

In order to take an extreme position in the market, and purchase only one of the outcomes for a quantity of $Q$ currency tokens, one must first mint $Q$ pairs of outcomes, and then, through the liquidity pool, swap the total $Q$ of the undesired tokens for desired ones. Thus, the amount of the desired outcome type purchased for $Q$ currency tokens is $Q + Q_{swap}$, where $Q_{swap}$ denominates the output amount of a fixed input swap according to the above described liquidity pool mathematics.

### Market resolution

At the creation of a prediction market in Krisa, a Tezos address has to be specified which has the ability to resolve the market (ie. attest to the outcome having become known). For live markets, this address is expected to be a Tezos smart contract, serving as business logic and a transform over the data provided by a trusted on-chain oracle, to ensure reliability and accuracy of the result.

Once a market had been resolved, outcome tokens pertaining to the confirmed outcome expire at a price of $1 - \sigma$ in currency tokens, while their counterparts expire at a value of $0$.

## Liquidity seeding and auction phase

Given the fact that Uniswap-style liquidity pools perform unpredictably in an and anomalous manner at very low liquidity, *Krisa* includes a feature that allows for raising liquidity for a nascent market in a fair manner, maximizing the log utility of bets. After a pre-defined auction period, the auction may be cleared, and bets in the auction converted into positions in the open market.

Suppose there are $I$ participants. Auction participant $i$ must provide their estimate probability $0 \le p_i \le 1$ of a $yes$ outcome (the probability of a $no$ outcome implied as $1 - p_i$), as well as locking up a quantity of $Q_i$ currency tokens in their bet.

### Clearing prices and allocation

Allocations are calculated by assuming implicitly trades between participants at a single clearing price, so as to maximize their log utility. Assuming that the clearing price vector is $(P, (1-P))$, and that each participant $i$ ends up with a position of quantities $({q_i}_{yes}, {q_i}_{no})$ in the two outcomes.

First, no $yes$ or $no$ tokens are created or destroyed:

$$\sum_{i=1}^I {q_i}_{yes} = \sum_{i=1}^I {q_i}_{no} = \sum_{i=1}^I Q_i$$

Second, everyone trades at the clearing price:

$$\forall i,~{q_i}_{yes} P + {q_i}_{no} (1 - P) = Q_i$$

Third, expected log utility should be maximized for everyone:

$$\forall i,~{p_i} \log {q_i}_{yes} + (1 - {p_i}) \log {q_i}_{no}$$

It's not necessarily obvious that all these constraints can be simulatenously met, but they can. We set the clearing price to the weighted arithmetic average:

$$P = \frac{\sum_{i=1}^I {Q_i}~{p_i}}{\sum_{i=1}^I {Q_i}}$$

We set the quantities participants end up with to:

$${q_i}_{yes} = Q_i \frac{p_i}{P},~{q_i}_{no} = Q_i \frac{1 - p_i}{1 - P}$$

### Seeding the liquidity pool

As the goal of the auction phase is to collect sufficient liquidity in the pool to make regular trading possible, all auction participants become liquidity providers, and thus co-owners of the market, to the extent of their ability to contribute in the correct proportion of tokens. Let

$$g_i = \min ((P~{q_i}_{yes}), ~((1-P){q_i}_{no})).$$

For every participant $i$, the contributions ${C_i}_{yes}$ and ${C_i}_{no}$ will be determined as

$${C_i}_{yes} = \frac{g_i}{P}, ~{C_i}_{no} = \frac{g_i}{1-P}$$

Finally, liquidity shares will be allocated to each participant $i$ for their contribution at a ratio of

$$\frac{g_i}{\sum_{i=1}^I g_i},$$

which in practice means an allocation of $g_i$ liquidity share tokens to each auction participant $i$, and a total initial supply of liquidity tokens of $\sum_{i=1}^I g_i$.

After funding the liquidity pool, each auction participant is left with a number of liquidity share tokens, as well as a number of their more preferred outcome tokens, depending the certainty of their preciction. For a bet of exactly $p_i = \frac{1}{2}$, the participant is left with liquidity share tokens only, and no outcome tokens (in line with a lack of preference toward any outcome).

## Fee and reward mechanics

For discussion of the reward mechanics built into Uniswap-style liquidity pools through the swap fee $\rho$ described above, see ([Zhang et al., 2018](https://github.com/runtimeverification/verified-smart-contracts/blob/uniswap/uniswap/x-y-k.pdf)). In a prediction market, due to the limited lifespan of the market, and potential market imperfection before resolution happens, there is a chance for the so-called *impermanent loss* to become permanent, which may act as an incentive for participants to prematurely withdraw liquidity from the market.

To counterbalance this effect, liquidity providers are allocated reward tokens on a time-proportionate basis. For each participant $i$ holding liquidity share tokens ${S_i}_d$, an equal amount of reward tokens will be (lazily) minted at the inclusion of block $d$. After the market had been resolved, each reward token will correspond to a proportionate share of the liquidity provider reward pool, which is $80\%$ of the total income collected through the redemption fee $\sigma$.

The other $20\%$ of the redemption fee income is allocated to the market creator.
