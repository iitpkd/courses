{-# LANGUAGE
    RecordWildCards
#-}
import           Data.List
import qualified Data.Set     as Set
import           Course
import           System.Environment
import           Text.Pandoc


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
latexFiles refFile fps = do rs <-  readFile refFile
                            concat <$> mapM (latex rs) fps

-- | Given a set of course description files generate the references.
references :: [FilePath] -> IO String
references = fmap refs . mapM readMeta
  where ref cm@(CourseMeta{..}) = "[" ++ code ++ "]: #" ++ labelString cm
        refs = unlines . map ref


latex :: String -> FilePath -> IO String
latex refs fp = do
  mta <- readMeta fp
  toLaTeX mta <$> readMarkdownFile refs fp
  where toLaTeX cmeta pdoc = unlines [ courseHead cmeta
                                     , writeLaTeX def pdoc
                                     ]
        courseHead cmeta = unlines [chapter cmeta, label cmeta, summary cmeta]



summary :: CourseMeta -> String
summary CourseMeta{..} = descriptionList [ ("Course Code"        , code                           )
                                         , ("Category"           , category                       )
                                         , ("Credits"            , credits                        )
                                         , ("Instructor Consent" , consentToStr consent           )
                                         , ("Pre-requisites"     , unwords $ map courseCode prereq)
                                         ]
  where consentToStr c | c          = "required"
                       | otherwise  = "automatic"



readMarkdownFile :: String -> FilePath -> IO Pandoc
readMarkdownFile refs fp = ioPDoc >>= either err return
  where attachRefs s     = unlines [s, "", "", refs]
        readIt           = readMarkdown readerOpts . attachRefs
        ioPDoc           = readIt <$> readFile fp
        err e            = fail $ unwords [fp ++ ": " , show e]
        readerOpts       = def { readerExtensions = Set.insert Ext_yaml_metadata_block defaultExts }
        defaultExts      = readerExtensions def


-------------------------- LaTeX helpers -----------------


courseLabelString cd = "course-" ++ cd
labelString = courseLabelString . code

-- | A general latex macro
macro nm args = "\\" ++ nm ++ concatMap braces args
  where braces x = "{" ++ x ++ "}"

macroOpt nm Nothing  = macro nm
macroOpt nm (Just x) = macro (nm ++ optArg)
  where optArg = "[" ++ x ++ "]"

-- | Some specific latex macros
chapter    CourseMeta{..} = macro "chapter" [code ++ ": " ++ title]
label cmeta           = macro "label" [courseLabelString $ code cmeta]

-- | Course code
courseCode s    = macro ("hyperref" ++ "[" ++ courseLabelString s ++ "]")[s]
begin s         = macro "begin" s
end   s         = macro "end"   [s]
item  i         = macroOpt "item" (Just i)[]
description i d = item i ++ " " ++ d

descriptionList s = unlines $ [begin ["labeling", hint]] ++
                    [description i d | (i, d) <- s] ++
                    [end "labeling"]
  where sz = maximum $ map (length . fst) s
        hint = replicate sz 'a'
