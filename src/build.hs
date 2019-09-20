import Development.Shake
import Slick

------------------------- The rules to build -----------------
buildRules :: Action ()
buildRules = return ()

------------------------ The driver program -----------------
main :: IO ()
main = slick buildRules