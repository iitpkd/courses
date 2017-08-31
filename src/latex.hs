{-# LANGUAGE
    RecordWildCards
  , OverloadedStrings
#-}
import           Data.List
import           Data.Monoid
import qualified Data.Set     as Set
import           Data.String
import           Course
import           System.Environment
import           Text.Pandoc

-- | Options used to read the document.
readerOpts :: ReaderOptions
readerOpts = def { readerExtensions = Set.insert Ext_yaml_metadata_block defaultExts }
  where defaultExts = readerExtensions def

-- | Writer options.
writerOpts :: WriterOptions
writerOpts = def

main :: IO ()
main = do args <- getArgs
          progN <- getProgName
          let usage = unlines [ "usage:"
                              , unwords [progN, "refs", "[FILE1 FILE2 ...]"]
                              , unwords [progN, "latex", "REFFILE", "[FILE1 FILE2 ...]"]
                              ]
          case args of
            "refs"   : xs           -> references xs         >>= putStrLn
            "latex"  : refFile : xs -> latexFiles refFile xs >>= putStrLn
            _                       -> fail usage

-- | Compile the set of latex
latexFiles :: FilePath -> [FilePath] -> IO String
latexFiles refFile fps = do
  rs      <-  readFile refFile
  process <$> mapM (readMarkdownFile rs) fps
  where process = writeLaTeX writerOpts . mconcat

-- | Given a set of course description files generate the references.
references :: [FilePath] -> IO String
references = fmap refs . mapM readMeta
  where ref cm@(CourseMeta{..}) = "[" ++ code ++ "]: #" ++ labelString cm
        refs = unlines . map ref



readMarkdownFile :: String -> FilePath -> IO Pandoc
readMarkdownFile refs fp = do
  mta      <- readMeta fp
  contents <- readFile fp
  let head         = header mta
      attachRefs s = unlines [s, "", "", refs]
      document     = mappend head <$> readMarkdown readerOpts (attachRefs contents)
      err e        = fail $ unwords [fp ++ ": " , show e]
    in either err return document


-----------------  Some helpers -----------------------------------

-- | The label associated with a course.
courseLabelString cd = "course-" ++ cd
labelString          = courseLabelString . code

-------------------------- LaTeX helpers -----------------


-- | A general latex macro
macro nm args = "\\" ++ nm ++ concatMap braces args
  where braces x = "{" ++ x ++ "}"

-- | Some specific latex macros
chapter    CourseMeta{..} = macro "chapter" [code ++ ": " ++ title]
label      cmeta          = macro "label"   [labelString cmeta]

header :: CourseMeta -> Pandoc
header cmeta = Pandoc mempty [Plain [RawInline "latex" $ unwords [chapter cmeta, label cmeta]]]
               <> metaInfo cmeta

-- | Creates a definition list with
metaInfo :: CourseMeta -> Pandoc
metaInfo CourseMeta{..} = Pandoc mempty [
  DefinitionList $ map wrap [ ("Course Code"        , [Str code])
                            , ("Category"           , [Str category])
                            , ("Credits"            , [Str credits])
                            , ("Instructor Consent" , consentToBlocks consent)
                            , ("Pre-requisites"     , intersperse (Str ", ") $ map courseLink prereq)
                            ]
  ]
  where consentToBlocks c | c          = [Str "required"]
                          | otherwise  = [Str "automatic"]
        wrap (i,d) = ([Str i], [ [Plain d]])


-- | Course code
courseLink s    = Link nullAttr ([Str s]) ("#" ++ courseLabelString s,s)
