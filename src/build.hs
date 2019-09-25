{-# LANGUAGE OverloadedStrings #-}

import           Data.Aeson
import           Data.Default
import           Data.HashMap.Strict as H
import           Data.Text           hiding (unwords)
import qualified Data.Vector         as V
import           Development.Shake
import           Slick
import           Slick.Pandoc
import           System.FilePath
import           Text.Pandoc


-- | Where are the courses.
courses :: [FilePath]
courses = ["cse/*.md"]

-- | Where to build the intermediate files.
artefact :: FilePath
artefact = ".artefact"


texSrcDir :: FilePath
texSrcDir = artefact </> "latex"

optReader :: ReaderOptions
optReader = def { readerExtensions = exts }
  where exts = readerExtensions def
               <> multimarkdownExtensions
               <> extensionsFromList [Ext_yaml_metadata_block]

optWriter :: WriterOptions
optWriter = def



------------------------ The driver program -----------------
main :: IO ()
main = slick buildRules



buildRules :: Action ()
buildRules = do
  _ <- buildCourses
  liftIO $ putStrLn "done"


--------------------- Courses --------------------------------
buildCourses :: Action ()
buildCourses = getDirectoryFiles "." courses >>= mapM_ buildCourse

buildCourse :: FilePath -> Action ()
buildCourse fp = do
  liftIO $ putStrLn fp
  courseToLaTeX fp

courseDestName    :: FilePath -> FilePath
courseDestName fp = texSrcDir </>replaceExtensions (takeFileName fp) "tex"


-- | Compile the course with course compiler.
courseToLaTeX :: FilePath -> Action ()
courseToLaTeX fp = do
  txt <- readFile' fp
  let rdr  = readMarkdown optReader
      wrr  = writeLaTeX optWriter
      transMeta = normaliseCode fp . adjustPrereq fp
    in do cs       <- transMeta <$> loadUsing rdr wrr (pack txt)
          rendered <- renderWithTemplate "src/templates/course.tex" cs
          writeFile' (courseDestName fp) (unpack rendered)

-- | Render with a given template.
renderWithTemplate :: FilePath -> Value -> Action Text
renderWithTemplate templateFile v = do
  template  <- compileTemplate' templateFile
  return $ substitute template v



--------------------------- Some helper function for processing values ---------------------

-- | Adjust the field of a metadata to suit the template.
adjustField :: Text -> (Value -> Value) -> FilePath -> Value -> Value
adjustField key tr _ (Object o) = Object $ H.adjust tr key o
adjustField key  _ fp  _         = error $ unwords ["adjust", unpack key ++ ":",  fp ++ ":", "improper meta data"]

-- | Adjust the prerequisites field to suite the template.
adjustPrereq :: FilePath -> Value -> Value
adjustPrereq = adjustField "prereq" (attachPrefix "course")
  where attachPrefix pre (Array v) = Array $ V.map (Object . H.singleton pre) v
        attachPrefix _   _         = error "attachPrefix: expecting an array"

-- | Normalise the course code to all caps.
normaliseCode :: FilePath -> Value -> Value
normaliseCode = adjustField "code" normCode
  where normCode (String t) = String $ toUpper t
        normCode _          = error "normaliseCode: expected string but got something else"
