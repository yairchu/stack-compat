{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Exception (finally)
import qualified Control.Lens as Lens
import           Control.Lens.Operators
import qualified Data.Aeson.Lens as AesonLens
import qualified Data.ByteString as BS
import qualified Data.Vector as Vector
import qualified Data.Yaml as Yaml
import           System.Directory (getHomeDirectory, removeFile)
import           System.Environment (getArgs)
import           System.Process (callProcess)

main :: IO ()
main =
    do
        srcRaw <- BS.readFile "stack.yaml"
        src <- Yaml.decodeThrow srcRaw :: IO Yaml.Value
        src
            & AesonLens.key "packages" . AesonLens._Array %~
                Vector.filter (Lens.nullOf (AesonLens.key "location"))
            & AesonLens.key "extra-deps" . AesonLens._Array <>~
                Vector.fromList
                (src ^..
                    AesonLens.key "packages" .
                    AesonLens.values . AesonLens.key "location")
            & Yaml.encodeFile "stack.yaml"
        home <- getHomeDirectory
        getArgs >>= callProcess (home <> "/.local/bin/stack")
            & (`finally` BS.writeFile "stack.yaml" srcRaw)
        -- Remove "stack.yaml.lock" artifact left by Stack 2,
        -- for usage in scripts which expect behavior to match Stack 1's.
        removeFile "stack.yaml.lock"
