module Mueval.Resources (limitResources) where

import System.Posix.Process (nice)
import System.Posix.Resource -- (Resource(..), ResourceLimits, setResourceLimit)
import System.Directory (setCurrentDirectory)

-- | Pull together several methods of reducing priority and easy access to resources:
--   nice, rlimits, and "cd".
limitResources :: IO ()
limitResources = do setCurrentDirectory "/tmp" -- will at least mess up relative links
                    nice 19 -- Set our process priority way down
                    mapM_ (uncurry setResourceLimit) limits

-- | Set all the available rlimits.
--   These values have been determined through trial-and-error
totalMemoryLimitSoft, totalMemoryLimitHard, stackSizeLimitSoft, stackSizeLimitHard,
 openFilesLimitSoft, openFilesLimitHard, fileSizeLimitSoft, fileSizeLimitHard, dataSizeLimitSoft,
 dataSizeLimitHard, cpuTimeLimitSoft, cpuTimeLimitHard, coreSizeLimitSoft, coreSizeLimitHard, zero :: ResourceLimit
totalMemoryLimitSoft = dataSizeLimitSoft
totalMemoryLimitHard = dataSizeLimitHard
-- These limits seem to be useless
stackSizeLimitSoft = zero
stackSizeLimitHard = zero
-- We allow one file to be opened, package.conf, because it is necessary. This
-- doesn't seem to be security problem because it'll be opened at the module
-- stage, before code ever evaluates.
openFilesLimitSoft = openFilesLimitHard
openFilesLimitHard = ResourceLimit 8
fileSizeLimitSoft = fileSizeLimitHard
fileSizeLimitHard = zero
dataSizeLimitSoft = dataSizeLimitHard
dataSizeLimitHard = ResourceLimit $ 6^(12::Int)
-- These should not be identical, to give the XCPU handler time to trigger
cpuTimeLimitSoft = ResourceLimit 4
cpuTimeLimitHard = ResourceLimit 5
coreSizeLimitSoft = coreSizeLimitHard
coreSizeLimitHard = zero
zero = ResourceLimit 0

limits :: [(Resource, ResourceLimits)]
limits = [ (ResourceStackSize,    ResourceLimits stackSizeLimitSoft stackSizeLimitHard)
         , (ResourceTotalMemory,  ResourceLimits totalMemoryLimitSoft totalMemoryLimitHard)
         , (ResourceOpenFiles,    ResourceLimits openFilesLimitSoft openFilesLimitHard)
         , (ResourceFileSize,     ResourceLimits fileSizeLimitSoft fileSizeLimitHard)
         , (ResourceDataSize,     ResourceLimits dataSizeLimitSoft dataSizeLimitHard)
         , (ResourceCoreFileSize, ResourceLimits coreSizeLimitSoft coreSizeLimitHard)
         , (ResourceCPUTime,      ResourceLimits cpuTimeLimitSoft cpuTimeLimitHard)]
