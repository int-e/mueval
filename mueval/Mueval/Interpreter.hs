-- TODO: suggest the convenience functions be put into Hint proper?
module Mueval.Interpreter (interpreterSession, printInterpreterError, ModuleName) where

import Control.Monad.Trans (liftIO)
import qualified Control.Exception (catch)

import Language.Haskell.Interpreter.GHC (eval, newSession, reset, setImports,
                                         setOptimizations, setUseLanguageExtensions, setInstalledModsAreInScopeQualified,
                                                         typeChecks, typeOf, withSession,
                                         Interpreter, InterpreterError, ModuleName, Optimizations(All))

import qualified Mueval.Resources (limitResources)


say :: String -> Interpreter ()
say = liftIO . putStr . take 1024

printInterpreterError :: InterpreterError -> IO ()
printInterpreterError = error . take 1024 . ("Oops... " ++) . show

interpreter :: Bool -> [ModuleName] -> String -> Interpreter ()
interpreter prt modules expr = do
                                  setUseLanguageExtensions False -- Don't trust the
                                                                 -- extensions
                                  setOptimizations All -- Maybe optimization will make
                                                       -- more programs terminate.
                                  reset -- Make sure nothing is available
                                  setInstalledModsAreInScopeQualified False
                                  setImports modules

                                  checks <- typeChecks expr
                                  liftIO Mueval.Resources.limitResources
                                  if checks then do
                                              if prt then do say =<< typeOf expr
                                                             say "\n"
                                               else return ()
                                              result <- eval expr
                                              say $ show result ++ "\n"
                                    else error "Expression did not type check."

interpreterSession :: Bool -> [ModuleName] -> String -> IO ()
interpreterSession prt mds expr = Control.Exception.catch
                                  (newSession >>= (flip withSession) (interpreter prt mds expr))
                                  (\_ -> error "Expression did not compile.")