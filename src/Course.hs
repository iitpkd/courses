{-# LANGUAGE
  DeriveGeneric
, OverloadedStrings
#-}

module Course(CourseMeta(..), readMeta) where


import           Control.Monad
import qualified Data.ByteString.Lazy.Char8 as L
import           Data.Yaml
import qualified Data.Text    as T
import qualified Data.Vector  as V
import           GHC.Generics



data CourseMeta = CourseMeta { code     :: [String]
                             , prereq   :: [String]
                             , title    :: String
                             , category :: String
                             , credits  :: String
                             , consent  :: Bool
                             } deriving (Generic, Show)

instance FromJSON CourseMeta where
  parseJSON (Object v) = CourseMeta
                         <$> codeParser
                         <*> prereqParser
                         <*> strField "title"
                         <*> strField "category"
                         <*> strField "credits"
                         <*> v .: "consent"

    where codeParser   = v .: "code"   >>= listOfStrings >>= atLeastOne
          prereqParser = v .: "prereq" >>= listOfStrings
          strField f   = v .: f        >>= toString

          listOfStrings (Array arr) = mapM toString $ V.toList arr
          listOfStrings Null        = return []
          listOfStrings obj         = (:[]) <$> toString obj


          atLeastOne lst | null lst  = fail "list should be aleast of size one"
                         | otherwise = return lst

          toString (String t)       = return $ T.unpack t
          toString obj              = fail "expected String" obj


instance ToJSON CourseMeta


getMetaDataBlock :: [L.ByteString] -> Either String L.ByteString
getMetaDataBlock [] = Left "meta block empty"
getMetaDataBlock (x:xs)
  | hyphen x = Right $ L.unlines $ takeWhile (not . hyphen) xs
  | otherwise = Left "no meta data block found."
  where hyphen s =  L.unwords (L.words s) == "---"

meta :: L.ByteString -> Either String CourseMeta
meta bs = do str <- getMetaDataBlock $ L.lines bs
             myDecode $ L.toStrict str
  where myDecode str = case decodeEither' str of
                         Right x -> Right x
                         Left  e -> Left $ prettyPrintParseException e

-- | Read the metadata from the file
readMeta :: FilePath -> IO CourseMeta
readMeta fp = do
  res <- meta <$> L.readFile fp
  either err return res
  where err x = fail $ unwords ["meta-data:error:", "in", fp ++ ":", x ]
