module Paths_apters_web (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName
  ) where

import Data.Version (Version(..))
import System.Environment (getEnv)

version :: Version
version = Version {versionBranch = [0,0,0], versionTags = []}

bindir, libdir, datadir, libexecdir :: FilePath

bindir     = "/Users/tehgeekmeister/Library/Haskell/ghc-7.0.3/lib/apters-web-0.0.0/bin"
libdir     = "/Users/tehgeekmeister/Library/Haskell/ghc-7.0.3/lib/apters-web-0.0.0/lib"
datadir    = "/Users/tehgeekmeister/Library/Haskell/ghc-7.0.3/lib/apters-web-0.0.0/share"
libexecdir = "/Users/tehgeekmeister/Library/Haskell/ghc-7.0.3/lib/apters-web-0.0.0/libexec"

getBinDir, getLibDir, getDataDir, getLibexecDir :: IO FilePath
getBinDir = catch (getEnv "apters_web_bindir") (\_ -> return bindir)
getLibDir = catch (getEnv "apters_web_libdir") (\_ -> return libdir)
getDataDir = catch (getEnv "apters_web_datadir") (\_ -> return datadir)
getLibexecDir = catch (getEnv "apters_web_libexecdir") (\_ -> return libexecdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
