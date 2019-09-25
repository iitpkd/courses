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
      transMeta = adjustPrereq fp . addLabel fp
    in do cs       <- transMeta <$> loadUsing rdr wrr (pack txt)
          rendered <- renderWithTemplate "src/templates/course.tex" cs
          writeFile' (courseDestName fp) (unpack rendered)


-- | Compute the code for the course.
getCode :: FilePath -> Value -> Value
getCode fp v = case v of
  Object o -> normaliseCode $ H.lookupDefault err "code" o
  _        -> err
  where err = error $ unwords ["course:", fp, ": no course code available"]


-- | Render with a given template.
renderWithTemplate :: FilePath -> Value -> Action Text
renderWithTemplate templateFile v = do
  template  <- compileTemplate' templateFile
  return $ substitute template v



--------------------------- Some helper function for processing values ---------------------

-- | Convert a given array of values with a single prefix. Useful for listing in Mustache tempates.
attachPrefix :: Text -> Value -> Value
attachPrefix pre (Array v) = Array $ V.map (Object . H.singleton pre) v
attachPrefix _   _         = error "attachPrefix: expecting an array"

-- | Adjust the prerequisites field to suite the template.
adjustPrereq :: FilePath -> Value -> Value
adjustPrereq _  (Object o) = Object $ H.adjust  (attachPrefix "course") "prereq" o
adjustPrereq fp _           = error $ unwords ["course:", fp, ": improper meta data"]

addLabel :: FilePath -> Value -> Value
addLabel fp obj@(Object o)= Object $ H.insert "label" l o
  where l = label $ getCode fp obj

label :: Value -> Value
label (String t) = String $ "syllabus-" <> toLower t
label _          = error "label: expected string but got something else"

normaliseCode :: Value -> Value
normaliseCode (String t) = String $ toUpper t
normaliseCode _          = error "normaliseCode: expected string but got something else"
