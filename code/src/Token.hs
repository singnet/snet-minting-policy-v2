{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeApplications  #-}

module Token
  ( 
    saveTokenPolicy,
    mintingCurrencySymbol,
    saveTestTokenPolicy
  ) where


import           Plutus.V1.Ledger.Value     (flattenValue)
import           Plutus.V2.Ledger.Contexts  (txSignedBy)
import           Plutus.V2.Ledger.Api       (CurrencySymbol,
                                             MintingPolicy, PubKeyHash,
                                             ScriptContext (scriptContextTxInfo),
                                             TokenName,
                                             TxInfo (txInfoMint),
                                             mkMintingPolicyScript)
import qualified PlutusTx
import           PlutusTx.Prelude         
import           Prelude               as P hiding (fst, snd, ($), (&&), (.), (<),
                                        (<>), (==),  (/=), all, (||))
import           Text.Printf           (printf)
import           Utilities             (currencySymbol, wrapPolicy, writePolicyToFile)


{-# INLINEABLE mkPolicy #-}
mkPolicy :: [PubKeyHash] -> TokenName -> BuiltinData -> ScriptContext -> Bool
mkPolicy owners name _ ctx = isCorrectToken && (isBurning || isSignedByAllOwners)
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    nameAmount :: (TokenName, Integer)
    nameAmount = case flattenValue $ txInfoMint info of
        [(_, name', amt)] -> (name', amt)
        _                 -> traceError "expected only one minting policy"

    isCorrectToken :: Bool
    isCorrectToken = fst nameAmount == name

    isSignedByAllOwners :: Bool
    isSignedByAllOwners = all (txSignedBy info) owners

    isBurning :: Bool
    isBurning = snd nameAmount < 0


{-# INLINABLE mkWrappedPolicy #-}
mkWrappedPolicy :: [PubKeyHash] -> TokenName -> BuiltinData -> BuiltinData -> ()
mkWrappedPolicy owners tokenName = wrapPolicy $ mkPolicy owners tokenName

policy :: [PubKeyHash] -> TokenName -> MintingPolicy
policy owners tokenName = mkMintingPolicyScript $
    $$(PlutusTx.compile [|| mkWrappedPolicy ||])
        `PlutusTx.applyCode` PlutusTx.liftCode owners
        `PlutusTx.applyCode` PlutusTx.liftCode tokenName

mintingCurrencySymbol :: [PubKeyHash] -> TokenName -> CurrencySymbol
mintingCurrencySymbol owners name  = currencySymbol $ policy owners name


saveTokenPolicy:: [PubKeyHash] -> TokenName -> IO ()
saveTokenPolicy owners tokenName = writePolicyToFile
  (printf "../scripts/token.plutus") $
    policy owners tokenName


-- FOR TESTS
saveTestTokenPolicy:: IO ()
saveTestTokenPolicy = writePolicyToFile
  (printf "../scripts/testToken.plutus") $
    policy testOwners testTokenName

testOwners:: [PubKeyHash]
testOwners = [
  "2a83c7337d41ecaae97eeca7b5d0084d7e92cf2ffd63b7a050e081c5",
  "72685a71048aec57d28d426a9a54bbef55853ac6baac469b70917249",
  "cca20bf9b05c9b8701bf8355bcad6821207033054f4f535fe40084d0"]

testTokenName :: TokenName
testTokenName = "NTOKEN"
