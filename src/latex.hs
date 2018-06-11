{-# LANGUAGE
    RecordWildCards
  , OverloadedStrings
#-}
import           Data.Char
import           Data.List
import           Data.Monoid
import qualified Data.Set     as Set
import           Course
import           System.Environment
import           Text.Pandoc
import           Text.Pandoc.Walk

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
  where ref cm@(CourseMeta{..}) = map singleRef $ labelStrings cm
        singleRef ccode = "[" ++ ccode ++ "]: #" ++ ccode
        refs = unlines . concatMap ref



readMarkdownFile :: String -> FilePath -> IO Pandoc
readMarkdownFile refs fp = do
  mta      <- readMeta fp
  contents <- readFile fp
  let hdr          = header mta
      attachRefs s = unlines [s, "", "", refs]
      document     = mappend hdr <$> readMarkdown readerOpts (attachRefs contents)
      err e        = fail $ unwords [fp ++ ": " , show e]
      attachCode   :: Block -> Block
      attachCode (Header n (idf,clz,kvp) inl) = Header n (head (code mta) ++ "-" ++ idf, clz,kvp) inl
      attachCode x                            = x
     in either err (return . walk attachCode) document



-----------------  Some helpers -----------------------------------

-- | The label associated with a course.
courseLabelString :: String -> String
courseLabelString cd = "course-" ++ map toUpper cd

labelStrings :: CourseMeta -> [String]
labelStrings = map courseLabelString . code

-------------------------- LaTeX helpers -----------------

multiCode = intercalate "/"



-- | A general latex macro
macro :: String -> [String] -> String
macro nm args = "\\" ++ nm ++ concatMap braces args
  where braces x = "{" ++ x ++ "}"

-- | Some specific latex macros
chapter :: CourseMeta -> String
chapter CourseMeta{..} = macro "chapter" [multiCode code ++ ": " ++ title]

hypertarget       :: CourseMeta -> String
hypertarget        = unlines . map htarget . code
  where htarget c  = macro "hypertarget" [courseLabelString c,""]

header :: CourseMeta -> Pandoc
header cmeta = Pandoc mempty [Plain [RawInline "latex" $ unwords [chapter cmeta, hypertarget cmeta]]]
               <> metaInfo cmeta

-- | Creates a definition list with
metaInfo :: CourseMeta -> Pandoc
metaInfo CourseMeta{..} = Pandoc mempty [
  DefinitionList $ map wrap [ ("Course Code"        , [Str $ multiCode code])
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
courseLink :: String -> Inline
courseLink s    = Link nullAttr ([Str s]) ("#" ++ courseLabelString s,s)
