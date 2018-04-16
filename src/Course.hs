{-# LANGUAGE
  DeriveGeneric
, OverloadedStrings
#-}

module Course(CourseMeta(..), readMeta) where


import qualified Data.ByteString.Lazy.Char8 as L
import           Data.Yaml
import           GHC.Generics


data CourseMeta = CourseMeta { code     :: String
                             , title    :: String
                             , category :: String
                             , credits  :: String
                             , consent  :: Bool
                             , prereq   :: [String]
                             } deriving (Generic, Show)

instance FromJSON CourseMeta
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
