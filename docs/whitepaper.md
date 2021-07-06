# Krisa* : A Decentralized Prediction Market Platform

( * - Working name; *Krisa* was the original name of the site of the Delphoi shrine to Apollo according to the Homeric hymns. )

*Krisa* is an automated system developed as an open source smart contract for the Tezos blockchain, that allows users to create and participate in binary prediction markets.

## Binary prediction market

Prediction markets are exchange-traded markets created for the purpose of trading the outcome of events. The market prices can indicate what the crowd thinks the probability of the event is.

A binary prediction market can resolve according two $2$ different outcomes, designated as $yes$ and $no$ answers pertaining to a prediction. Once the answer becomes known, the market is resolved to one of these two outcomes, at which point the correct prediction expires at a price of $100\%$, and the incorrect at $0\%$. ([Wikipedia](https://en.wikipedia.org/wiki/Prediction_market))

In Krisa, the open trading phase of the market is realized using a liquidity pool based on the $x * y = k$ mathematics pioneered by Uniswap v1. This is a decentralized exchange technology, where a single liquidity pool serves as automated market maker, providing exchange of two assets for one another at spot prices based on the built-in mathematics. The fundamental concept is as follows:

$$x_0 * y_0 = x_1 * y_1 = k$$

Where $x_0$ and $y_0$ are the original asset amounts in the pool, while $x_1$ and $y_1$ those after the exchange. In reality, a fee is collected on each swap, which means $k$ will in effect slowly grow over time, which provides incentive for keeping liquidity in the pool, for a share of its ownership.

An exchange of $\Delta x$ of one asset for $\Delta y$ of the other would thus be described by the following equation, assuming a fee of $0 \leq \rho \lt 1$:

$$x_0 * y_0 = (x_0 + (1-\rho)\Delta x) * (y_0 - \Delta y) $$

The swap fee implemented in *Krisa* is in line with the Uniswap fee at $0.3\%$ or $\rho = 0.003$. ([Zhang et al., 2018](https://github.com/runtimeverification/verified-smart-contracts/blob/uniswap/uniswap/x-y-k.pdf))

### Entering and exiting the market

In Krisa, the $yes$ and $no$ outcome contracts are represented as FA2 fungible tokens connected to the market in question. In an open market, entering and exiting the market is realized by respectively minting and burning outcome token pairs.

Each pair of outcome tokens is nominally equivalent to $1$ currency token specified at market creation, in which the market is denominated. By locking up $1$ currency token in the market, one has the ability to mint a pair consisting of a $yes$ and $no$ tokens.

In reality, outcome tokens are discounted by a minting fee, which serves to incentivize market creators to drive traffic to the market, as well as an serving as an additional reward to liquidity providers, to offset the distortions expected at the tail end of a market lifecycle.

Thus, the discounted value of an outcome token pair is $1 * (1 - \sigma)$, where $\sigma$ is a different and separate fee from the above mentioned uniswap fee, set in *Krisa* as $5\%$ or $\sigma = 0.05$.

In an open market, $1 * (1 - \sigma)$ currency token may be unlocked by burning a pair of outcome tokens.

### Market resolution

At the creation of a prediction market in Krisa, a Tezos address has to be specified which has the ability to resolve the market (ie. attest to the outcome having become known). For live markets, this address is expected to be a Tezos smart contract, serving as business logic and a transform over the data provided by a trusted on-chain oracle, to ensure reliability and accuracy of the result.

Once a market had been resolved, $1$ contract pertaining to the confirmed outcome expires at a price of $1 * (1 - \sigma)$ currency tokens, while its counterpart expires at a value of $0$.

## Liquidity seeding and auction phase

Given the fact that Uniswap-style liquidity pools perform unpredictably in an and anomalous manner at very low liquidity, *Krisa* includes a feature that allows for raising liquidity for a nascent market in a fair manner, maximizing the log utility of bets. After a pre-defined auction period, the auction may be cleared, and bets in the auction converted into positions in the open market.

Suppose there are $I$ participants. Auction participant $i$ must provide their estimate probability $0 \le p_i \le 1$ of a $yes$ outcome (the probability of a $no$ outcome implied as $1 - p_i$), as well as locking up a quantity of $Q_i$ currency tokens in their bet.

The clearing mathematics for a $K$ outcome auction are as below (Breitman, 2021). In the case of the binary market, $K = 2$ is assumed, as well as a prediction vector of $(p_i, (1-p_i))$ for each participant $i$.

## $K$ outcome auction mathematics (Breitman, 2021)

$$\forall i,~ \left(\sum_{k=1}^K {p_i}_k = 1 \wedge \forall k,~0 \leq {p_k}_i \leq 1\right)$$

We assume the auction participants will trade with each other at a single clearing price so as to maximize their log utility. Assume that the clearing price vector is $P$, and that participant $i$ ends up with a position of quantity ${q_i}_k$ in outcome $k$.

First, nothing should be created, and nothing should be destroyed:

$$\forall k,~\sum_{i=1}^I {q_i}_k = \sum_{i=1}^I Q_i$$

Second, everyone trades at the clearing price:

$$\forall i,~\sum_{k=1}^K {q_i}_k P_k = Q_i$$

Third, expected log utility $\sum_{k=1}^K {p_i}_k \log {q_i}_k$ should be maximized for everyone

$$\forall i,~\forall k, ~\sum_{k=1}^K {p_i}_k \log {q_i}_k$$

It's not necessarily obvious that all these constraints can be simulatenously met, but they can.

We set the clearing price to the weighted arithmetic average:

$$\forall k,~P_k = \frac{\sum_{i=1}^I {Q_i}~{p_i}_k}{\sum_{i=1}^I {Q_i}}$$

We set the quantities participants end up with to:

$${q_i}_k = \frac{Q_i {p_i}_k }{P_k}$$

The first constraint is now met:

$$\forall k, \sum_{i=1}^I {q_i}_k = \frac{1}{P_k} \sum_{i=1}^I {Q_i} {p_i}_k = \frac{\sum_{i=1}^I {Q_i}}{\sum_{i=1}^I {Q_i}~{p_i}_k} \sum_{i=1}^I {Q_i} {p_i}_k = \sum_{i=1}^I {Q_i}$$

The second constraint is also met:

$$\forall i,~\sum_{k=1}^K {q_i}_k P_k = \sum_{k=1}^K Q_i {p_i}_k = Q_i \sum_{k=1}^K {p_i}_k = Q_i$$

Finally, it is known that $\sum_{k=1}^K {p_i}_k \log {q_i}_k$ is maximized when the vector $q_i$ is collinear with the vector $p_i$.

### But is it incentive compatible?

Say user $i$'s true $p$ is $p_i^\ast$ but they instead pretend it's $p_i$.

Their true utility as a function of their declared $p_i$ is thus
$$U(p_i) = \sum_{k=1}^K {p_i}_k^\ast \log \left( Q_i {p_i}_k\right)-\sum_{k=1}^K {p_i}_k^\ast \log (P_k)$$

Define
$$V(p_i,\lambda) = U(p_i) - \lambda\left(1-\sum_{k=1}^K {p_i}_k\right)$$

We are looking for a stationary point of $V$.

$$\frac{\partial V}{\partial {p_i}_l} = \frac{{p_i}_l^\ast}{{p_i}_l} - \frac{Q_i {p_i}_l^\ast }{\sum_{j=1}^I Q_j {p_j}_l} + \lambda$$

Right away it doesn't look like ${p_i}_l^\ast = {p_i}_l$ will produce a stationary point.

$$\frac{\partial V}{\partial \lambda} = 1-\sum_{k=1}^K {p_i}_k$$

$$\forall l, \frac{{p_i}_l^\ast}{{p_i}_l} = \lambda - \frac{Q_i {p_i}_l^\ast }{Q_i {p_i}_l + \sum_{j=1,j \neq i}^I Q_j {p_j}_l}$$

### Uniswap funding

We form a constant product uniswap contract which holds quantities $r_1, \ldots, r_K$ of each outcome token and tries to maintain $r_1 \times \ldots \times r_K$ constant (almost constant, it takes some fees).

Suppose I want to trade a quantity $\Delta_{k_1}$ of outcome ${k_1}$ and receive $\Delta_{k_2}$ of outcome ${k_2}$. We try to keep

$$(r_{k_1} + \Delta_{k_1}) (r_{k_2} - \Delta_{k_2}) \prod_{k=1,k\neq k_1,k \neq k_2}^K r_k = r_{k_1} r_{k_2} \prod_{k=1,k\neq k_1,k \neq k_2}^K r_k$$

This is equivalent to ensuring $$(r_{k_1} + \Delta_{k_1}) (r_{k_2} - \Delta_{k_2}) = r_{k_1} r_{k_2}$$.

This is, in fact, exactly equivalent the equation for a two-asset uniswap contract, so the same logic can be used although it could be extended to accomodate more generic request, (e.g. I have such and such outcome tokens, I want such and such outcome tokens in such proportions).

For this uniswap contract to imply the clearing price $P$, we simply need $\forall k,~r_k = C/P_k$ for some constant $C$. 

We would like to fund this uniswap contract while maximizing $C$. We first perform the clearing step of the auction, then each participant contributes as many tokens as they can to the uniswap contract, in the right proportion.

Let
$$g_i = \min_{k = 0}^K P_k~{q_i}_k$$

For all $k$, user $i$ contributes $g_i / P_k$ tokens of outcome k to the uniswap and receives a share $g_i / \sum_{i=1}^I g_i$ of the pool.