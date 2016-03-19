module MulticastSpec where

import Test.Hspec
import Test.Hspec.QuickCheck

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "Multicast" $ do
    it "trivially true" $ do
      True `shouldBe` True
    prop "add is commutative" $ \x y ->
       x + (y :: Int) `shouldBe` y + x
