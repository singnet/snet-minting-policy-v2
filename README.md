# snet-minting-policy-v2

Use the provided VSCode devcontainer to get an environment with the correct tools set up.
This approach is the easiest & fastest one. Clone repository and open it in VSCode.

## Installation tips for NodeJs
```sh
    cd code
    npm i
    npm i --save-dev @types/node
```

## Compile `Token.hs`

```sh
    cd code
    cabal build
```

## Get test PlutusScriptV2 for `Token.hs`

In `Token.hs` you can specify:
 - testOwners
 - testTokenName

```sh
    cd code
    cabal repl
    > saveTestTokenPolicy
```

## Run tests 

In `secret.ts` file  in `code` folder specify:
- blockfrostKey
- owner1PrivateKey
- owner2PrivateKey
- owner3PrivateKey
- payerPrivateKey

In `offchain.ts` you can also specify your own PlutusScriptV2 for `Token.hs` in variables:
- scriptWith1Signer
- scriptWith2Signers
- scriptWith3Signers

Plutus scripts are received from `.plutus` file(s) that are saved by  `Token.hs` module from [previous step](#run-tests)

```sh
    deno run -A ./src/offchain.ts
```
