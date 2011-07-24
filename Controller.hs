{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Controller
    ( withFoundation
    , withDevelApp
    ) where

import Foundation
import Settings
import Yesod.Helpers.Static
import Yesod.Helpers.Auth
import Database.Persist.GenericSql
import Data.ByteString (ByteString)
import Data.Dynamic (Dynamic, toDyn)
import Store.File
import Store.Base
import Control.Exception hiding (Handler)
import Data.Enumerator (enumEOF, ($=))
import qualified Data.Enumerator.List as EL
import Blaze.ByteString.Builder (fromByteString)
import Data.Aeson (toJSON, ToJSON)
import Yesod.Json

-- Import all relevant handler modules here.
import Handler.Root

-- This line actually creates our YesodSite instance. It is the second half
-- of the call to mkYesodData which occurs in Foundation.hs. Please see
-- the comments there for more details.
mkYesodDispatch "Foundation" resourcesFoundation

-- Some default handlers that ship with the Yesod site template. You will
-- very rarely need to modify this.
getFaviconR :: Handler ()
getFaviconR = sendFile "image/x-icon" "config/favicon.ico"

getRobotsR :: Handler RepPlain
getRobotsR = return $ RepPlain $ toContent ("User-agent: *" :: ByteString)

-- This function allocates resources (such as a database connection pool),
-- performs initialization and creates a WAI application. This is also the
-- place to put your migrate statements to have automatic database
-- migrations handled by Yesod.
withFoundation :: (Application -> IO a) -> IO a
withFoundation f = Settings.withConnectionPool $ \p -> do
    runConnectionPool (runMigration migrateAll) p
    let h = Foundation s p
    toWaiApp h >>= f
  where
    s = static Settings.staticdir

withDevelApp :: Dynamic
withDevelApp = toDyn (withFoundation :: (Application -> IO ()) -> IO ())

-- our code starts here

echo :: ToJSON a => a -> GHandler sub master RepJson
echo = jsonToRepJson . toJSON

getBuildR = wrapStoreAction build

getNewR = wrapStoreAction newRepo

getFindR = wrapStoreAction findRepos

getGetR = wrapStoreAction getRepo

wrapStoreAction f arg = do
    result <- liftIO $ f defaultFileStore arg
    echo result

getExportR name = return (("application/x-tar"::ContentType), ContentEnum $ export defaultFileStore name $= EL.map fromByteString)

defaultFileStore = fileStore "./stores/default"
